/*
 * Copyright (C) 2020 The LineageOS Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.lineageos.settings.thermal;

import android.app.ActivityTaskManager;
import android.app.ActivityTaskManager.RootTaskInfo;
import android.app.IActivityTaskManager;
import android.app.Service;
import android.app.TaskStackListener;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;
import android.os.PowerManager;
import android.os.RemoteException;
import android.util.Log;

public class ThermalService extends Service {

    private static final String TAG = "ThermalService";

    private final Handler mHandler = new Handler(Looper.getMainLooper());
    private String mPreviousApp;
    private ThermalUtils mThermalUtils;
    private PowerManager mPowerManager;
    private IActivityTaskManager mActivityTaskManager;
    private volatile boolean mDestroyed;

    private final BroadcastReceiver mIntentReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            mPreviousApp = null;
            updateThermalProfile();
        }
    };

    @Override
    public void onCreate() {
        super.onCreate();
        mThermalUtils = new ThermalUtils(this);
        mPowerManager = getSystemService(PowerManager.class);
        mActivityTaskManager = ActivityTaskManager.getService();
        try {
            mActivityTaskManager.registerTaskStackListener(mTaskListener);
        } catch (RemoteException e) {
            Log.w(TAG, "Unable to register task listener", e);
        }
        IntentFilter filter = new IntentFilter();
        filter.addAction(Intent.ACTION_SCREEN_OFF);
        filter.addAction(Intent.ACTION_SCREEN_ON);
        registerReceiver(mIntentReceiver, filter);
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        updateThermalProfile();
        return START_STICKY;
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public void onDestroy() {
        mDestroyed = true;
        mHandler.removeCallbacksAndMessages(null);
        unregisterReceiver(mIntentReceiver);
        try {
            mActivityTaskManager.unregisterTaskStackListener(mTaskListener);
        } catch (RemoteException e) {
            Log.w(TAG, "Unable to unregister task listener", e);
        }
        mThermalUtils.setDefaultThermalProfile();
        super.onDestroy();
    }

    private void updateThermalProfile() {
        if (mDestroyed) {
            return;
        }
        if (!mPowerManager.isInteractive()) {
            mPreviousApp = null;
            mThermalUtils.setDefaultThermalProfile();
            return;
        }
        try {
            final RootTaskInfo info = mActivityTaskManager.getFocusedRootTaskInfo();
            if (info == null || info.topActivity == null) {
                return;
            }
            String foregroundApp = info.topActivity.getPackageName();
            if (!foregroundApp.equals(mPreviousApp)) {
                mThermalUtils.setThermalProfile(foregroundApp);
                mPreviousApp = foregroundApp;
            }
        } catch (RemoteException e) {
            Log.w(TAG, "Unable to read focused task", e);
        }
    }

    private final TaskStackListener mTaskListener = new TaskStackListener() {
        @Override
        public void onTaskStackChanged() {
            if (!mDestroyed) {
                mHandler.post(ThermalService.this::updateThermalProfile);
            }
        }
    };
}

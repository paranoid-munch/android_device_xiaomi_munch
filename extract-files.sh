#!/bin/bash
#
# SPDX-FileCopyrightText: 2016 The CyanogenMod Project
# SPDX-FileCopyrightText: 2017-2024 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

set -e

DEVICE=munch
VENDOR=xiaomi

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}/../../.."

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

ONLY_FIRMWARE=
KANG=
SECTION=

while [ "${#}" -gt 0 ]; do
    case "${1}" in
        --only-firmware)
            ONLY_FIRMWARE=true
            ;;
        -n | --no-cleanup)
            CLEAN_VENDOR=false
            ;;
        -k | --kang)
            KANG="--kang"
            ;;
        -s | --section)
            SECTION="${2}"
            shift
            CLEAN_VENDOR=false
            ;;
        *)
            SRC="${1}"
            ;;
    esac
    shift
done

if [ -z "${SRC}" ]; then
    SRC="adb"
fi

function blob_fixup() {
    case "${1}" in
        vendor/etc/init/init.batterysecret.rc)
            [ "$2" = "" ] && return 0
            sed -i '/seclabel u:r:batterysecret:s0/d' "${2}"
            ;;
        vendor/etc/libnfc-nci.conf)
            [ "$2" = "" ] && return 0
            grep -q "LEGACY_MIFARE_READER=1" "${2}" || echo "LEGACY_MIFARE_READER=1" >> "${2}"
            ;;
        vendor/lib/libaudioroute_ext.so|vendor/lib/hw/audio.primary.kona.so)
            [ "$2" = "" ] && return 0
            "${PATCHELF}" --replace-needed "libaudioroute.so" "libaudioroute-v34.so" "${2}"
            ;;
        vendor/lib64/camera/components/com.mi.node.watermark.so)
            [ "$2" = "" ] && return 0
            "${PATCHELF}" --add-needed "libpiex_shim.so" "${2}"
            ;;
        vendor/lib64/hw/camera.qcom.so)
            [ "$2" = "" ] && return 0
            sed -i 's|st_license.lic|camera_cnf.txt|g' "${2}"
            ;;
        vendor/lib64/libMIAIHDRhvx_interface.so|vendor/lib64/libarcsoft_hdrplus_hvx_stub.so)
            [ "$2" = "" ] && return 0
            "${PATCHELF}" --clear-symbol-version "remote_handle_close" "${2}"
            "${PATCHELF}" --clear-symbol-version "remote_handle_invoke" "${2}"
            "${PATCHELF}" --clear-symbol-version "remote_handle_open" "${2}"
            ;;
        vendor/lib64/libarcsoft_super_night_raw.so)
            [ "$2" = "" ] && return 0
            "${PATCHELF}" --clear-symbol-version "rpcmem_alloc" "${2}"
            "${PATCHELF}" --clear-symbol-version "rpcmem_free" "${2}"
            "${PATCHELF}" --clear-symbol-version "rpcmem_to_fd" "${2}"
            ;;
        vendor/lib64/vendor.qti.hardware.camera.postproc@1.0-service-impl.so)
            [ "$2" = "" ] && return 0
            xxd -p "${2}" | tr -d '\n' | sed 's/9a0a0094/1f2003d5/g' | xxd -r -p > "${2}.tmp" && mv "${2}.tmp" "${2}"
            ;;
        system_ext/lib64/libwfdnative.so)
            [ "$2" = "" ] && return 0
            "${PATCHELF}" --add-needed "libinput_shim.so" "${2}"
            ;;
        vendor/etc/init/init.mi_thermald.rc)
            [ "$2" = "" ] && return 0
            sed -i '/seclabel u:r:mi_thermald:s0/d' "${2}"
            ;;
        vendor/etc/seccomp_policy/atfwd@2.0.policy)
            [ "$2" = "" ] && return 0
            grep -q "gettid: 1" "${2}" || echo "gettid: 1" >> "${2}"
            ;;
        vendor/lib64/libril-qc-hal-qmi.so)
            [ "$2" = "" ] && return 0
            sed -i 's|ro.product.vendor.device|ro.vendor.radio.midevice|g' "${2}"
            ;;
        vendor/lib64/libwvhidl.so|vendor/lib64/mediadrm/libwvdrmengine.so)
            [ "$2" = "" ] && return 0
            "${PATCHELF}" --add-needed "libcrypto_shim.so" "${2}"
            ;;
        vendor/etc/msm_irqbalance.conf)
            [ "$2" = "" ] && return 0
            sed -i 's/IGNORED_IRQ=27,23,38/IGNORED_IRQ=27,23,38,267,305/g' "${2}"
            ;;
        vendor/etc/init/vendor.qti.media.c2@1.0-service.rc)
            [ "$2" = "" ] && return 0
            sed -i 's|writepid /dev/cpuset/foreground/tasks|task_profiles ProcessCapacityHigh HighPerformance|g' "${2}"
            ;;
        vendor/lib/libstagefright_soft_ac4dec.so|vendor/lib/libstagefright_soft_ddpdec.so|vendor/lib/libstagefrightdolby.so|vendor/lib64/libdlbdsservice.so|vendor/lib64/libstagefright_soft_ac4dec.so|vendor/lib64/libstagefright_soft_ddpdec.so|vendor/lib64/libstagefrightdolby.so)
            [ "$2" = "" ] && return 0
            "${PATCHELF}" --replace-needed "libstagefright_foundation.so" "libstagefright_foundation-v33.so" "${2}"
            ;;
        *)
            return 1
            ;;
    esac

    return 0
}

function blob_fixup_dry() {
    blob_fixup "$1" ""
}

# Initialize the helper
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false "${CLEAN_VENDOR}"

if [ -z "${ONLY_FIRMWARE}" ]; then
    extract "${MY_DIR}/proprietary-files.txt" "${SRC}" "${KANG}" --section "${SECTION}"
fi

"${MY_DIR}/setup-makefiles.sh"

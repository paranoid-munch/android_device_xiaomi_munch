# Выполненные исправления munch CLO DT

Обновление 2026-10-28 после разрешения владельца на исправления. Дерево предназначено только для munch, включая его варианты POCO F4 / Redmi K40S. Варианты не удалены; fingerprints, provisioning identity и параметры NFC сохранены.

| Коммит | Исправление | Выполненная проверка |
|---|---|---|
| `73896e7` | D01: удалены SQLite MEMORY/OFF/OFF overrides | XML parse, отсутствие трёх device overrides; effective defaults на телефоне ещё проверить |
| `11a7cd2` | D02: таблица variants перенесена в libvariant_default, устранены два определения | Host linker воспроизвёл multiple definition до правки; после правки C++20 с -Wall -Wextra -Werror линкуется, assertions всех трёх вариантов проходят |
| `aa6ea5e` | D03: проверяются ровно шесть thermal groups и их порядок/префиксы | javac/java harness на настоящем ThermalUtils.java со stub Android API: повреждённые preferences, сохранение корректных назначений, все семь состояний и streaming write проходят |
| `e306ce6` | D05: удалён эквивалентный дубликат SCO WB mixer path | До удаления оба path раскрыты в одинаковый control/value; после удаления имена уникальны, ссылки разрешаются |
| `07cf52d` | D05: удалены одинаковые property, BoardConfig flag и FM blob entry | Сохранены первые определения, удалённые строки побайтно совпадали по содержимому с ними |
| `74e766d` | D04: абсолютный sysfs path в существующем условном FOD trigger | Diff check; trigger и нода сохранены. Применимость trigger на munch не доказана |

Каждый коммит исправления содержит `Co-authored-by: Codex <codex@openai.com>`. Полная Android/Soong сборка и проверки на устройстве не выполнены. Host harnesses проверяют конкретную логику и линковку, но не заменяют Android runtime. Временные harnesses находятся за пределами репозитория, в /tmp.

Итоговые статические проверки после шести исправлений: все 48 XML корректны; bash -n для 9 scripts проходит; локальные property keys уникальны; base mixer names уникальны и вложенные ссылки разрешаются; git diff --check проходит.

**Оставлено на диагностике:** D06 (DAC/factory calibration writers), Wi-Fi capability flags и empty-channel parser, device-ID attestation, RKP, audio PCM/ACDB, AVB release model и BPF/kernel override. Нет достаточных данных для их технически обоснованного изменения. Для GMS Safety Center, RoleController и WLC исправляемые исходники/APK в checkout отсутствуют. Не добавлены фиктивные HAL, permission exemptions или отключения защиты.

HBM не изменялся: просьба о его удалении отменена владельцем. Репозитории не клонировались, внешние конфиги не сравнивались. На устройстве ничего не прошивалось и не записывалось.

Ниже сохранён **исходный аудит снимка c7a1679 до исправлений**. Все его номера строк, результаты первоначальных проверок и формулировки «исходники не изменены» относятся к этому исходному этапу. Текущий статус исправлений указан в таблице выше.

---

# Аудит munch CLO DT: AOSPA beryl / Android 16 QPR0

Дата: 2026-10-28. Состояние: диагностика, без исправления исходников.

## 1. Резюме и границы достоверности

Исследован отдельный репозиторий `/home/kdyrolzhas/clomunch`, ветка `beryl`, HEAD `c7a1679` (`munch: Add support for DolbyAtmos`). По уточнению владельца это DT для **AOSPA beryl, Android 16 QPR0**. Идентификация ROM и версии Android предоставлена владельцем; полный manifest сборки и итоговые build properties отсутствуют. Успешная загрузка устройства также известна со слов владельца, а не проверена этим аудитом.

Полный файл журнала обработан построчно: 17 347 строк, 2 414 061 байт, SHA-256 `675112a04412938175faad40fdc3f9ff818ebdb4b62eec793a116de59c3c3e27`. Выполнены агрегация всех тегов ошибок/предупреждений, поиск аварий и зависимостей, подробное чтение контекстов значимых событий. Это не аппаратный тест и не семантическая проверка каждой операции каждого приложения.

**Важное отличие пути:** `./log.txt` в репозитории отсутствует. Фактически исследован `/home/kdyrolzhas/log.txt`. Ниже `log:N` означает номер строки именно этого файла. Журнал не копировался в отчёт, значения персональных идентификаторов и параметры аттестации исключены.

Реальные приоритеты:

1. Убрать небезопасные SQLite overrides `MEMORY/OFF/OFF` после проверки эффективного overlay: это конкретный риск целостности пользовательских БД.
2. Проверить двойное определение `variants` в libinit и соответствие локального снимка исходникам успешной сборки.
3. Исправить проверку количества термопрофилей XiaomiParts: пять полей принимаются, но код обращается к шестому.
4. Проверить согласованность device-ID attestation с идентичностью, передаваемой TEE. Ошибка аттестации подтверждена, её точная причина пока не доказана.
5. Проверить audio PCM/mixer/ACDB для speaker feedback и ultrasound на фактическом ядре; не менять калибровки.
6. Wi-Fi сначала проверить с включённым интерфейсом: первые `getUsableChannels` следуют за выгрузкой драйвера. Объявлять Wi-Fi сломанным по этому журналу нельзя.

Подтверждённых CRITICAL аппаратных неисправностей, отказа загрузки, потери данных или повреждения разделов не обнаружено. SQLite-конфигурация имеет потенциально критичные последствия, но фактическая потеря данных не зарегистрирована. Ни один исправляющий патч не применён.

Уточнение объёма пользователя: **только munch CLO DT**. Репозитории AOSPA, vendor, hardware и kernel не клонировались. Внешние конфиги ROM не использовались для сравнения. Для интерпретации отдельных API и SQLite использованы официальные справочные материалы, ссылки приведены рядом с выводами. Они не заменяют исходники конкретной сборки.

## 2. Структура, наследование и конечная конфигурация

### 2.1. Что доступно

В корне: `BoardConfig.mk`, `device.mk`, `Android.bp`, `proprietary-files.txt`, extract/setup scripts; каталоги `configs`, `libinit`, `overlay`, `parts`, `rootdir`, `sepolicy`. До создания отчёта автоматическим проходом прочитаны 165 файлов исходников/конфигураций, 32 618 строк. Локальных инструкций AGENTS.md внутри DT нет.

Это **не** полный checkout Android. Отсутствуют `device/xiaomi/sm8250-common`, `vendor/xiaomi/munch`, `kernel/xiaomi/*`, реализации Qualcomm HAL, Framework и PermissionController. `device/xiaomi/munch` — ожидаемое место установки этого репозитория в Android tree, а не существующий вложенный каталог здесь (`BoardConfig.mk:7`).

Отсутствуют `AndroidProducts.mk`, product entrypoint `*_munch.mk`, `vendorsetup.sh`, dependency manifest. Это ограничение воспроизводимости данного checkout, а не доказательство отсутствия файлов в исходной успешной сборке.

### 2.2. Доступная цепочка

```text
[внешний product AOSPA: отсутствует]
  -> device/xiaomi/munch/device.mk [факт вызова извне проверить нельзя]
       :8   frameworks/native/build/phone-xhdpi-6144-dalvik-heap.mk
       :11  vendor/xiaomi/miuicamera/miuicamera.mk [if-exists]
       :14  vendor/dolby/dolby.mk [обязательный]
       :53  $(SRC_TARGET_DIR)/product/virtual_ab_ota/launch_with_vendor_ramdisk.mk
       :516 vendor/qcom/opensource/vibrator/vibrator-vendor-product.mk
       :541 vendor/xiaomi/munch/munch-vendor.mk

[выбор BoardConfig внешней системой сборки]
  -> BoardConfig.mk
       :125-129 configs/props/{odm,product,system,system_ext,vendor}.prop
       :141-143 system_ext public/private и vendor SELinux
       :161-164 hardware/xiaomi VINTF matrix + локальные matrix и manifest
       :167 vendor/xiaomi/munch/BoardConfigVendor.mk [обычный include, в конце]
```

`TARGET_COMMON_QTI_COMPONENTS` перечисляет adreno/alarm/av/bt/charging/overlay/perf/telephony/wfd/wlan (`device.mk:420-430`), но обработчик переменной отсутствует. Поэтому нельзя считать доказанным, какие HAL и APK он добавляет. Аналогично нет определения `LOCAL_PATH` в начале `device.mk`: ряд путей зависит от корректного значения, установленного вызывающей конфигурацией. Это нужно сверить при dumpvars, а не автоматически менять на `DEVICE_PATH` без полного окружения.

Последующий `BoardConfigVendor.mk` способен переопределить локальные board-переменные. Итоговые product packages/properties зависят от внешнего product и правил merge Android build. Простой текстовый порядок не заменяет вычисление inheritance.

### 2.3. Установленные значения

| Параметр | Доказательство и предел вывода |
|---|---|
| ROM | AOSPA beryl / Android 16 QPR0 — уточнение владельца; локальная ветка `beryl` |
| SoC/platform | `TARGET_BOARD_PLATFORM := kona`, `BoardConfig.mk:122`; SM8250-AC указан в README |
| Архитектура | arm64 + arm, `BoardConfig.mk:25-38` |
| Shipping API | `PRODUCT_SHIPPING_API_LEVEL := 31`, `device.mk:489`; Android 12 в README |
| Vendor API / VNDK | Не определены локально; shipping API и vendor security patch не являются Vendor API |
| Vendor SPL | `2025-04-01`, `BoardConfig.mk:138`; дата сама по себе не доказывает актуальность бинарников |
| Происхождение blobs | Комментарий `proprietary-files.txt:1-2`: Android 13, V816.0.12.0.ULMMIXM / CN V816.0.10.0.ULMCNXM, unpinned |
| Kernel | `Image`, boot header 3, `vendor/munch_defconfig`, `BoardConfig.mk:74-85`; версия/ветка/исходники отсутствуют |
| BPF override | `ro.bpf.kver_override=5.10.239`, `configs/props/product.prop:2`; это не доказательство версии ядра |
| FCM | `target-level="5"`, `configs/vintf/manifest.xml:1`; не равен версии Android или Vendor API |
| Разделы | Dynamic partitions + virtual A/B, `BoardConfig.mk:93-118`, `device.mk:53,408` |
| SELinux | Локальных `permissive`/`dontaudit` не найдено; реальный enforcing не проверен |

FCM 5 и shipping API 31 следует проверить по итоговой матрице, но повышать target-level только из-за Android 16 неправильно: обновляемое устройство сохраняет ограничения исходного vendor stack.

### 2.4. HAL, которые действительно объявлены локально

| Подсистема | Локальное объявление | Сопоставление |
|---|---|---|
| Audio/effects | HIDL 6.0, manifest:2-10 | `device.mk:91-96` |
| Bluetooth HCI | HIDL 1.0, manifest:12-15 | Бинарник 1.0 в proprietary-files:88-90; библиотека 1.1 в device.mk:143 не доказывает сервис 1.1 |
| Camera | provider HIDL 2.4 legacy/0, manifest:17-20 | `device.mk:155-156` |
| Gatekeeper | HIDL 1.0, manifest:22-25 | proprietary-files:612-614 |
| Keymaster | HIDL 4.0/default, manifest:27-30 | proprietary-files:764-769; библиотека 4.1 в device.mk:281 не означает сервис 4.1 |
| Sensors | HIDL 1.0, manifest:32-35 | `device.mk:484-485` |
| SoundTrigger | HIDL 2.3, manifest:37-40 | `device.mk:95` |
| Radio | HIDL 1.5 IRadio и 1.2 ISap, manifest:167-174 | Библиотека radio@1.6 в device.mk:455 не повышает интерфейс сервиса |
| Radio config | HIDL 1.1, manifest:175-179 | Библиотека 1.3 в device.mk:456 не доказывает сервис 1.3 |
| IMS | vendor HIDL 1.7, manifest:202-207 | Итоговый IMS APK/ELF отсутствует |
| Perf/IOP | vendor HIDL 2.2 / 2.0, manifest:108-117 | Реализации из внешних QTI компонентов не доступны |
| Secure element | HIDL 1.2 eSE1, manifest:255-259 | init.xiaomi.rc:68-85 |
| Wi-Fi | В локальном manifest нет android.hardware.wifi | В log есть AIDL service; декларация может поступать из module fragment |
| NFC/USB/health/thermal/power/display | Пакеты в device.mk, часть AIDL по именам | Версии нельзя вывести из названий пакетов; нужны их VINTF fragments |

Локальная framework matrix содержит только optional `vendor.qti.hardware.audiohalext@1.0` (`configs/vintf/framework_compatibility_matrix.xml:2-8`). Отсутствие HAL в этом небольшом файле не означает отсутствие в объединённой матрице.

## 3. Подтверждённые дефекты и противоречия DT

### D01 — HIGH: небезопасные глобальные значения SQLite

**Источник:** `overlay/MunchFrameworksRes/res/values/config.xml:207,214,226`:

```xml
<string name="db_default_journal_mode" translatable="false">MEMORY</string>
<string name="db_default_sync_mode" translatable="false">OFF</string>
<string name="db_wal_sync_mode" translatable="false">OFF</string>
```

Ответственный компонент — framework resource overlay DT, добавленный через `device.mk:399-405`. Это доказанная небезопасная конфигурация исходников; её эффективное применение на устройстве ещё не подтверждено. Logcat не содержит доказательства повреждённой БД.

MEMORY хранит rollback journal в RAM и теряет возможность восстановления после аварии процесса в ходе транзакции. `synchronous=OFF` уменьшает гарантии при аварии ОС/питания. Это описано в [официальной документации SQLite](https://www.sqlite.org/pragma.html#pragma_journal_mode) и [synchronous](https://www.sqlite.org/pragma.html#pragma_synchronous). Не все приложения используют framework defaults, некоторые переопределяют PRAGMA.

**Последствия:** риск повреждения/потери данных у потребителей этих defaults; к Wi-Fi HAL и RKP напрямую не относится.

**Минимальное исправление:** удалить три device-specific override, наследовать проверенные defaults AOSPA; не назначать произвольные альтернативы без проверки Framework.

**Проверка:** effective resource lookup трёх ресурсов, сборка overlay, тест транзакций на отдельной временной БД тестового приложения. Не проверять риск отключением питания рабочего телефона и не запускать запись в пользовательские БД.

### D02 — MEDIUM: два внешних определения `variants` в libinit

**Источник:** `libinit/init_xiaomi_munch.cpp:56-60` определяет непустой `const std::vector<variant_info> variants`; `libinit/libvariant_default/libvariant_default.cpp:9` определяет такой же объект, но пустой. Объявление `extern` — `libinit/libvariant_headers/include/libvariant.h:26`. Обе реализации попадают в конфигурацию: основной .cpp в `libinit/Android.bp:9-12`, default library в `whole_static_libs` через select, `libinit/Android.bp:16-21`.

Это подтверждённое нарушение единственности определения на уровне выбранных исходников. При включении обоих объектов в конечный ELF ожидается multiple definition; фактический результат линковки не воспроизведён. При выборе внешней variant_lib надо отдельно проверить её содержимое. Успешная сборка владельца не позволяет утверждать, что именно эта default-ветка и эти объекты вошли в неё.

**Последствия:** проблема повторной сборки/переноса, риск расхождения логики выбора варианта; существующие runtime errors этим не объяснены.

**Минимальное исправление:** выбрать единственного владельца таблицы. Если варианты задаются в `init_xiaomi_munch.cpp`, исключить второе определение из реально подключаемой библиотеки; если архитектура предусматривает variant library — перенести таблицу в неё и убрать локальную. Не менять обе модели одновременно без анализа потребителя Soong config.

**Проверка:** значение `xiaomi_munch.variant_lib`, linker map/nm входных объектов и сборка `init_xiaomi_munch`/vendor init в AOSPA. Нужен один символ `variants`. Здесь C++/Soong сборка не запускалась.

### D03 — MEDIUM: некорректная проверка списка термопрофилей XiaomiParts

**Источник:** `parts/src/org/lineageos/settings/thermal/ThermalUtils.java:73-85`: `if (modes.length < 5) value = null;`. Дальше используются `modes[5]`: строки 111, 116, 135, 164.

**Первопричина:** конфигурация ровно из пяти непустых полей проходит проверку, хотя требуется шесть. Это воспроизводимое логическое противоречие. Стандартная строка содержит шесть меток, поэтому чистая установка сама по себе не обязана воспроизводить ошибку. Нужны старые/повреждённые preferences.

**Последствия:** `ArrayIndexOutOfBoundsException` при редактировании профиля; в task listener исключение поглощается (`ThermalService.java:99`), профиль может перестать применяться. Краш XiaomiParts в журнале не найден.

**Минимальный патч:** проверять ровно шесть ожидаемых полей и их метки, при неверной структуре восстанавливать безопасную default-строку. Для самого очевидного дефекта достаточно заменить `< 5` на `< 6`; строгая проверка схемы предпочтительнее.

**Проверка:** на тестовых preferences проверить 0/4/5/6 полей, выбор streaming, переключение приложения и screen off/on. Защитные thermal daemon и ограничения температуры не трогать.

### D04 — LOW: относительный путь sysfs в init

`rootdir/etc/init.target.rc:184-185`:

```rc
on property:persist.vendor.sys.fp.fod.large_field=1
    write sys/bus/i2c/devices/3-0049/fod_area 1
```

Отсутствует начальный `/`. Это подтверждённая зависимость от cwd init; если cwd `/`, путь может разрешиться корректно, поэтому безусловный отказ не утверждается. Кроме того, существование FOD-ноды на munch не подтверждено. Это условный, вероятно унаследованный фрагмент, а не доказанная причина проблем бокового сканера.

**Исправление:** при наличии реально используемой ноды сделать путь абсолютным; иначе отдельно обосновать удаление неприменимого trigger. **Проверка:** read-only проверка существования sysfs и свойств, поиск init failure. Не выставлять trigger ради эксперимента.

### D05 — LOW: дубликаты конфигурации

* `configs/props/vendor.prop:33,130`: одинаковое `ro.vendor.audio.us.proximity=true`. Противоречащих значений в пяти локальных prop-файлах не найдено.
* `BoardConfig.mk:66,144`: одинаковое `BUILD_BROKEN_VENDOR_PROPERTY_NAMESPACE := true`.
* `proprietary-files.txt:108,609`: одинаковое назначение `vendor/lib/vendor.qti.hardware.fm@1.0.so`.
* `configs/audio/mixer_paths.xml:1984,1988`: два разных определения пути `audio-record-compress2 bt-sco-wb`: первое включает `audio-record-compress2 bt-sco`, второе задаёт `MultiMedia17 Mixer SLIM_7_TX`.

Первые три пункта — избыточность, не доказанный runtime failure. Дубликат mixer path создаёт зависимость от поведения парсера/порядка; как именно работает vendor `libaudioroute-v34`, без реализации не установлено.

**Минимальное исправление:** удалить идентичные дубликаты; для mixer path сначала проверить parser и ожидаемую SCO WB-маршрутизацию, затем оставить единое согласованное определение. **Проверка:** повторная статическая проверка, генерация vendor makefiles в полном дереве, запись/звонок SCO WB. Не переименовывать mixer path по догадке.

### D06 — MEDIUM: избыточно открытые DAC permissions

`rootdir/etc/init.target.rc:321-343`: `0666 /dev/migt`, `0777` для параметров частот/boost, `0666 mi_viptask`. В этом же файле `:198-256` условный factory trigger копирует speaker calibration в persist и устанавливает `666` на файлы. Отдельно `:366-396` встречаются `0777` для camera model files.

Факт открытых modes подтверждён; доступ непривилегированного приложения не доказан, поскольку SELinux остаётся отдельным барьером. Нельзя объявлять наличие chmod доказанным обходом SELinux или фактом изменения persist.

**Риски:** слишком широкая поверхность записи для доменов с SELinux-доступом, влияние на энергопотребление/планировщик, условный риск целостности калибровок. Активация factory trigger в log не подтверждена.

**Предложение:** сначала построить список необходимых writers и меток, затем сузить DAC в исходниках до фактических UID/GID. Для factory-фрагмента — отдельно решить, нужен ли он custom ROM; не вызывать его и не менять существующие калибровки/permissions на телефоне в рамках диагностики. Универсального chmod-патча без анализа потребителей нет.

## 4. Wi-Fi — высокий приоритет расследования

### W01 — LOW, подтверждённое сообщение; причина функционального отказа не установлена

`log:8767-8784`, 02:05:48.313–.323: `wifi_get_usable_channels: Error -3 waiting for response`, `WifiChipAidlImpl ... code 4`; всего 152 вызова с ошибкой до 02:07:43.152. Нельзя приравнивать число `-3` к Linux errno или автоматически считать его таймаутом без определения status в выбранном Qualcomm HAL.

Ключевой контекст **до первой ошибки**:

* `log:8755-8760`, 02:05:48.310: драйвер сообщает код страны KZ и частоты 2.4/5 GHz, включая DFS.
* `log:8761`: список 6 GHz пуст.
* `log:8763-8766`: scanning disabled, **`wifi driver unloaded`**.
* `log:8767`: запрос usable channels после выгрузки.

Это сильная гипотеза неподдерживаемого запроса/запроса в неактивном состоянии. Последующие повторы следует проверить отдельно; отсутствие STA connect в этой записи не доказывает невозможность подключения. В log также есть `Unknown iface name: wlan0` (`:5003` и далее), что нужно привязать к lifecycle, а не лечить переименованием интерфейса.

**Конфигурация:** `device.mk:518-531` ставит supplicant, vendor hostapd/supplicant interface libraries, ini и symlinks; сам выбор Wi-Fi HAL, hostapd service и драйвера находится вне checkout, вероятно в QTI wlan-компоненте. `TARGET_COMMON_QTI_COMPONENTS` — только точка подключения, не исследованная реализация. Журнал показывает AIDL facade; внутренний legacy vendor HAL может оставаться Qualcomm C API. Наличие vendor HIDL supplicant libraries этому не противоречит.

**Исправление:** пока не предлагать DT-патч на замену AIDL/HIDL. Проверить advertised capability getUsableChannels, обработку unsupported в HAL и caller gating при выключенном Wi-Fi; при подтверждении исправлять соответствующий компонент.

**Валидация:** состояния Wi-Fi off / scan-only / STA connected / SoftAP; для каждого свежий короткий log, dumpsys wifi, сервисы, driver/kernel версия. Проверить доступ в сеть, reconnect, 2.4/5 GHz, suspend/resume. Не менять regulatory domain искусственно.

### W02 — LOW: пустой список каналов и парсер Framework

`overlay/MunchWifiRes/res/values/strings.xml:6,11,16` задаёт пустые `config_wifiSoftap{2g,5g,6g}ChannelList`. Комментарии прямо определяют пустую строку как отсутствие дополнительного ограничения. `log:8771,8780,8784` и далее: 96 `NumberFormatException: For input string: ""`, пойманных `ApConfigUtil`.

**Наиболее вероятная причина:** выбранная реализация парсера Android 16 QPR0 пытается разбирать пустое поле; связь с данными DT сильная, но effective overlay и конкретный исходник Wi-Fi module отсутствуют. Это не непойманный краш Wi-Fi.

**Минимальное исправление:** проверить соответствующий `convertStringToChannelList`/caller и отсутствие empty guard. Если пустая строка имеет документированную семантику, корректно обработать её в Framework; либо удалить ненужные overrides, если штатный ресурс ROM даёт правильное поведение. Заполнять `1-13` или каналы 5 GHz ради отсутствия сообщения неправильно: это не универсальная регуляторная политика.

**Проверка:** effective lookup ресурсов, юнит-тест парсера пустой/непустой строки в фактической Wi-Fi ветке и запуск SoftAP с клиентом. Не утверждается, что удаление override гарантированно устранит сообщение: default тоже может быть пустым.

### W03 — MEDIUM, гипотеза: завышенные SoftAP capabilities

`overlay/MunchWifiRes/res/values/bools.xml:19` — 6 GHz SoftAP=true; `:49,52,55` — HE beamformee/beamformer/802.11ax=true. `integers.xml:7` — 32 клиента. В журнале 6 GHz frequencies пусты; `WifiHotspotRepository` 56 раз сообщает unsupported bands (`log:8796,8800` и далее).

Пустой список 6 GHz в текущем regulatory/interface state не доказывает отсутствие диапазона в hardware. Общая поддержка 11ax чипсетом тоже не доказывает SoftAP HE. Для этой ревизии нужны реальные capabilities драйвера и firmware.

**Предложение:** сравнить ресурсы с HAL feature set, nl80211 iftypes и hostapd capabilities; снизить только доказанно неподдерживаемые флаги. Не отключать 11ax/DFS на основании имени SoC.

### W04 — INFORMATIONAL: NL80211 AKM attribute

`log:5030`–`:16882`: 225 `Failed to get NL80211_ATTR_MAX_NUM_AKM_SUITES`. Это отдельный optional capability query. Драйвер при этом возвращает диапазоны частот. Без версии kernel/nl80211 и wificond fallback нельзя определить пользовательский эффект. Не основание менять SELinux или firmware.

### Driver, regulatory, firmware и init

* `configs/wifi/WCNSS_qcom_cfg.ini:38` — DFS master=1, `:96` — DFS roam=1, `:193` — `gCountryCodePriority=1`. Код страны KZ реально поступает в Framework. Это наблюдение, не юридическая валидация конкретного регуляторного набора.
* `Android.bp:13-25`: symlink ini в `/vendor/firmware/wlan/qca_cld`, MAC — из `/mnt/vendor/persist/wlan_mac.bin`. Существование target MAC не проверено; значение не читалось.
* `rootdir/etc/init.target.rc:103-104` — cold calibration `cnss-qca6390/fs_ready`; sysfs даёт указание на QCA6390, но реализация kernel отсутствует.
* `rootdir/etc/init.qcom.rc:543-544`: старый `pronto_wlan.ko` включается **только** `vendor.wifi.ftmd.load=true`. Это factory trigger, не доказанный normal boot path; не объявлять причиной runtime Wi-Fi ошибок.
* `init.qcom.rc:546-554` определяет cnss-daemon и shutdown. Его binary/firmware может поступать из общего QTI wlan; отсутствие в локальном blob list не доказывает отсутствие в образе.
* Нет данных о фактическом modules.load, kernel config, WLAN firmware revisions, hostapd init fragment и DTBO. Полную совместимость здесь проверить невозможно.

## 5. Keystore, Keymaster, аттестация

### K01 — INFORMATIONAL: отсутствующий RKP interface не равен отсутствующему TEE

`log:1298-1308`, 02:02:48.273: `remote_provisioning.rs`, `Trying to get IRPC name`, `Failed to get rpc for sec level TRUSTED_ENVIRONMENT`, `HARDWARE_TYPE_UNAVAILABLE`. Всего 67 таких статусов, последний в 02:07:13.180.

Локально объявлен Keymaster 4.0/default, Gatekeeper 1.0 и QSEE. KeyMint, IRemotelyProvisionedComponent, StrongBox service/feature не найдены ни в manifest, ни в package/blob списках. Это legacy stack, **поддержка RKP этим набором не установлена**. Наличие `libkeymasterprovision.so` не доказывает Remote Key Provisioning. Нельзя уверенно судить о полном vendor image без его fragments.

[Документация AOSP RKP](https://source.android.com/docs/core/ota/modular-system/remote-key-provisioning) описывает отдельный provisioning-компонент. Сообщение именно о RPC lookup не доказывает отказ генерации обычного TEE-ключа или поломку шифрования userdata.

**Изменения:** не добавлять фиктивный RKP/KeyMint/StrongBox в VINTF и не включать RKP-only свойства. Проверить lshal/service list и VINTF образа; затем отдельно обычную TEE-генерацию ключа и factory attestation без ID. Здесь эти тесты не выполнены.

### K02 — MEDIUM: подтверждён отказ device-ID attestation; связь с DT вероятна

`device.mk:40` копирует `android.software.device_id_attestation.xml`. `log:1314` и далее содержит 54 `CANNOT_ATTEST_IDS`; `log:16503`, 02:07:13.194: `KeyAttestationHandler: Device supports DeviceIdAttestation, but KeyStoreException is caught with error code 8`. Этот отказ сохраняется после перехода GMS на 26.41.31.

В запросах встречаются теги идентичности brand/device/product/manufacturer/model и персональных ID, включая second IMEI. Значения намеренно не приводятся. По одному общему статусу нельзя определить, какой тег отвергнут: legacy Keymaster может отвергать unsupported тег, несовпадающее значение либо весь запрос.

Дополнительная гипотеза DT: `libinit/init_xiaomi_munch.cpp:14-53` задаёт варианты; `libinit/libinit_variant.cpp:42-55` переписывает product identity и fingerprints, а `libinit/libinit_utils.cpp:22-36` распространяет их на все partition namespaces. TEE может хранить исходные provisioning values. Все варианты используют схожую строку vendor build, но это не доказывает правильность ни регионального fingerprint, ни attestation ID. Manufacturing identity нельзя восстанавливать догадкой из маркетингового имени.

**Последствия:** отказ приложений, использующих ID attestation. Обычная аттестация без идентификаторов и защищённое хранение могут работать; это не проверено.

**Минимальное исправление — после разделяющих тестов:** если stack действительно не поддерживает ID attestation, перестать объявлять feature. Если отказ вызван неверной runtime identity, согласовать разрешённые build properties с исходным provisioning без подмены сертификатов. Если ломается только новый тег Framework, исправлять формирование/совместимость запросов на нужном уровне. Удаление feature не исправляет TEE и не должно скрывать полноценный дефект поддержки.

**Проверка:** feature list, сервисы, тест обычного hardware key, attestation без ID и отдельно допустимых вариантов ID тестовым инструментом в защищённой среде. В отчёт выгружать только статусы/типы тегов; не сертификаты, ID или сырые запросы. Не читать/стирать secure storage, RPMB, persist и EFS.

## 6. AppOps, RoleController и Safety Center

### P01 — MEDIUM: несовместимое действие RoleController / AppOps, вне DT

`log:1030-1052`, 02:02:46.359, и ещё 125 аналогичных blocked calls: `Blocked setUidMode call for runtime permission app op`, COARSE/FINE_LOCATION. Стек ведёт через `AppOpService.kt:272`, `AppOpsService`, `Permissions.setAppOpUidModeAsUser`, `grantPermissionAndAppOpAsUser`, `RoleControllerServiceImpl.onGrantDefaultRoles`.

Это конкретный старый путь назначения app-op для runtime permission при новом permission backend. Java RuntimeException здесь логируется; отсутствие FATAL для system_server не позволяет назвать это его крашем. Реальный отказ выдачи runtime location не проверен.

В DT есть только hotword privileged-permissions (`configs/permissions/privapp-permissions-hotword.xml:1-15`, копируется `device.mk:256`). Он не выдаёт location и не объясняет стек. Framework/PermissionController исходники отсутствуют; точного исправляемого файла в **этом** репозитории нет. Пути из stack trace не выдаются за доступные локальные исходники.

**Исправление:** согласовать PermissionController/RoleController с Android 16 QPR0 permission backend; для runtime permissions использовать корректный grant/revoke API. Не менять privapp allowlist, не выдавать location всем и не обходить AppOps.

**Проверка:** фактические версии APEX/APK, default roles, foreground/background location и deny/revoke сценарии на тестовом пользователе, повторный log после завершения обновлений.

`RoleControllerServiceImpl` также отвергает GMS для SYSTEM_CALL_STREAMING/DEPENDENCY_INSTALLER и supervision package (`log:9034` и далее). Вероятна несогласованность пакетов/role requirements, но XML с их назначением вне DT. Не дописывать недостающие привилегии без проверки qualification.

### S01 — MEDIUM: GMS AdvancedProtection отсутствует в активной конфигурации Safety Center

`log:7-31`, 02:02:42.252: Java FATAL в `com.google.android.gms`, `Unexpected safety source: AdvancedProtection`, GMS 25.15.32. Framework отвергает source ID, передаваемый GMS. Это подтверждённый crash и ошибка согласования source configuration; имя конкретного overlay-файла в ROM установить нельзя: локально нет `SafetyCenter`/`AdvancedProtection` ресурсов, GMS packages или safety_center_config.

Во время записи GMS заменяется: около `log:5941-5955`, 02:05:40; stack traces 26.41.31 впервые появляются `log:10117`, 02:05:50.237. После этого **повтор AdvancedProtection FATAL не обнаружен**, но окно наблюдения всего до 02:08:04.082. Обновление могло убрать несовместимость или просто не повторился trigger; причинное исправление не доказано.

**Предложение:** сначала повторить boot/idle с уже обновлённым GMS, установить эффективный safety config и согласовать поддерживаемый ID с пакетом. Не добавлять source ID без правильного типа/компонентов и не отключать Safety Center. В текущем DT править нечего на основании имеющихся данных.

**Проверка:** dumpsys safety_center и overlay list, затем тот же сценарий после обновления. Эти дампы перед публикацией обезличить: они могут содержать пользовательское состояние.

## 7. Qualcomm Workload Classifier

### Q01 — MEDIUM: подтверждённый несовместимый запуск background service, вне локального DT

`log:5941-5949`, 02:05:40.146: FATAL `WLCServiceStart`, `BackgroundServiceStartNotAllowedException`, action `PACKAGE_REMOVED`, `WLCReceiver$StartRunnable.run(WLCReceiver.java:60)` -> `Context.startService`. Рядом идут сообщения REPLACED/REMOVED для GMS.

Причина конкретного краша установлена: приложение запускает обычный сервис из background в контексте обработки package broadcast. Это не доказанный crash loop: за весь файл один WLC FATAL. APK workloadclassifier отсутствует в локальном `proprietary-files.txt`; вероятное включение через общий QTI perf нельзя доказать без внешнего product. Объявления perf/IOP HAL в manifest не доказывают обязательную зависимость от WLC.

**Последствия:** этот запуск classifier не выполняется, может не обновиться workload database; влияние на performance hints и батарею не измерено.

**Предложение:** найти точку включения APK и его targetSdk/исходники; адаптировать работу к JobScheduler/допустимой модели фоновой задачи с учётом требований обработки событий. FGS не универсальная замена. Удалять APK или делать background whitelist пока необоснованно.

**Проверка:** package install/update/remove в тестовом окружении, отсутствие FATAL, выполнение задачи, связь с Perf HAL; отдельно power hints под нагрузкой. Это не требует изменения модема или калибровок.

## 8. Телефония, NFC, Bluetooth и GPU

| Событие | Классификация и доказательства | Компонент / минимальное действие / проверка |
|---|---|---|
| `queryModemActivityInfo: invalid response` | LOW, 4 раза, `log:11168,11920,12453,17275`, 02:05:52–02:07:57 | Телеметрия RIL; Radio 1.5 в manifest:172-173. Не доказывает потерю регистрации. Проверить modem activity response отдельно от звонка/данных/IMS; патч пока не установлен |
| `queryNrIcon not supported in HIDL` | INFORMATIONAL, `log:13731-13734`, 02:06:07.078 | QtiRadioHidl явно отвергает дополнительный query. Vendor IQtiRadio 1.0/2.4 в manifest:225-235; это не два одинаковых fqname. Проверить fallback SystemUI и фактическую индикацию NSA/SA; не повышать HAL только заменой XML |
| `NFC must be enabled but is: 1` | INFORMATIONAL, `log:8173`, 02:05:48.031 | Запрос `isObserveModeSupported` при выключенном/неактивном adapter; enum конкретной ветки не проверен. Не доказывает отказ чтения NFC. init.xiaomi.rc:61-85 включает HAL/SE; конфиги в proprietary-files:817-819. Проверить enabled NFC, tag/HCE/SE раздельно |
| Bluetooth energy `error: 11` | INFORMATIONAL/LOW, `log:17309-17322`, 02:08:02.986 | AOSP BluetoothStatusCodes определяет 11 как FEATURE_NOT_SUPPORTED; вероятен неподдерживаемый energy report, а не отказ BT. Проверить выбранную ветку и controller capabilities, затем pairing/A2DP/HFP и energy отдельно |
| `Could not find QSPM HAL service` | INFORMATIONAL, `log:12728-12729`, 02:06:03.644 | Лог прямо говорит `Skipping adreno profile processing`. QSPM не объявлен локально. Нужность внешнему Adreno profile component не доказана. Не добавлять несуществующий сервис; проверить graphics отдельно |

Определение Bluetooth 11 сверено по [официальному исходнику AOSP](https://android.googlesource.com/platform/packages/modules/Bluetooth/+/refs/heads/main/framework/java/android/bluetooth/BluetoothStatusCodes.java); фактический source этой AOSPA сборки отсутствует.

Telephony overlays: `overlay/MunchFrameworksRes/res/values/config.xml:85-111` включает IMS-функции и binding; `:238-248` — SA/NSA и два physical slots; `:282` — `vendor.qti.iwlan`. `configs/props/system.prop` включает IMS availability overrides. Это объявления доступности, не подтверждение carrier provisioning. `overlay/MunchCarrierConfig/res/xml/vendor.xml` локально присутствует, но действующие carrier/IMS настройки не получены. `rootdir/etc/init.xiaomi.rc:99-100` задаёт `ro.vendor.radio.midevice`, что соответствует blob fixup в `extract-files.sh` для libril. Полный DT_NEEDED и ABI QCRIL/IMS без ELF не проверены.

NFC RF config в `proprietary-files.txt:817` намеренно переназначен в `vendor/libnfc-nxp_RF.conf`. Это необычное размещение, но без содержимого libnfc config нельзя назвать его ошибочным путём. `configs/props/system_ext.prop:2` указывает `libnfc-nci.conf`; extract fixup добавляет legacy MIFARE. Фактические firmware и HAL fragment недоступны.

## 9. Audio: подтверждённые неудачные операции, не доказанная неисправность воспроизведения

### A01 — MEDIUM, гипотеза несовместимости PCM/mixer/ACDB

Контекст 02:06:06.531 (`log:13427-13479`):

* `Invalid snd_device` в backend comparison, затем выбран и включён `speaker`.
* Применяются mixer paths `speaker`, `vi-feedback`, `spkr-vi-record`.
* `log:13447`: `Could not get ctl for mixer cmd - Audio Stream Capture 43 App Type Cfg`.
* `log:13460-13462`: ACDB persistent table возвращает `-18`.

В 02:07:56 есть ultrasound и voice-handset routing, missing capture controls 31/43 (`log:17094,17142`), ACDB id 7 с `-8/-19` (`log:17181-17220`). Это **не чистое бездействие**: идут аудиомаршрутизация и запросы сервисов. Нельзя все сообщения объявить startup noise.

Соответствующие исходники:

* `configs/audio/audio_platform_info_intcodec.xml:91`: `USECASE_AUDIO_SPKR_CALIB_TX id="43"` — конкретная связь с отсутствующим capture 43 control.
* `:141`: `SND_DEVICE_IN_CAPTURE_VI_FEEDBACK acdb_id="102"`, `:303` interface WSA_CDC_DMA_TX_0.
* `configs/audio/mixer_paths.xml:2565`: spkr-vi-record, `:3090`: vi-feedback.
* `proprietary-files.txt:4-13`: ACDB Tutu; `:64-65`: audio.primary.kona -> audio.primary.munch и переименование a2dp offload.
* `configs/props/vendor.prop:136`: `ro.hardware.audio.primary=munch`, согласовано с blob rename. Наличие собираемого `audio.primary.kona` в `device.mk:100` само по себе не доказывает, что загружены два primary HAL.
* `extract-files.sh` меняет libaudioroute dependency на v34; `device.mk:96` добавляет эту библиотеку. Гарантировать ABI и фактическое выполнение fixup без ELF нельзя.

**Наиболее вероятно:** несовпадение ожидаемых HAL mixer controls с kernel machine driver, либо optional/control-less PCM path, либо неполные таблицы под выбранный usecase. Ошибки ACDB сами по себе не означают потерю индивидуальных persist-калибровок: речь также об обычных vendor ACDB таблицах. Номера кодов ACDB без их реализации не расшифровывались как errno.

**Последствия:** возможное ухудшение speaker feedback/обработки, ultrasound proximity, voice route; фактический звук/качество/безопасность speaker protection не проверены. Лог применения path не доказывает слышимое воспроизведение.

**Предлагаемое исправление:** сначала `tinymix` inventory и `/proc/asound/pcm`, версия kernel/audio HAL, эффективный audio_platform_info и набор ACDB. После этого согласовать только конкретные PCM IDs/controls/таблицы. Не менять speaker gain, DSP topology IDs и calibration наугад; не отключать защиту динамиков.

**Проверка:** media оба динамика, voice earpiece/speaker, микрофоны, VoIP, Bluetooth SCO, USB audio, ultrasound proximity/screen off, после каждого соответствующий log. На умеренной громкости, без стресс-теста динамиков.

### Что не является найденным дефектом

Все audio XML синтаксически корректны. В основном mixer-файле все nested path references разрешаются. Static overlay отдельно ссылается на common paths, что предусмотрено его комментариями; после объединения множества base+static неразрешённых ссылок нет. Поэтому эти ссылки **не** записаны в баги.

Audio policy includes (`configs/audio/audio_policy_configuration.xml:402-416`) сопоставляются с local usbv2/volumes и внешними файлами, копируемыми `device.mk:129-137`. Их реальное наличие в образе не проверено, но явной опечатки destination по этому сопоставлению не найдено.

## 10. Дополнительный аудит: питание, безопасность, камера, сенсоры, USB

### 10.1. Deep sleep: подозрительный cmdline имеет компенсирующую запись

`BoardConfig.mk:78` содержит `lpm_levels.sleep_disabled=1`. Однако `rootdir/bin/init.qcom.post_boot.sh:5673-5843` содержит ветку **kona**, в конце `:5841` пишет `N` в `/sys/module/lpm_levels/parameters/sleep_disabled`. Сервис qcom-post-boot определён `rootdir/etc/init.qcom.rc:584-592`, запускается после boot_completed.

Поэтому утверждение «DT постоянно запрещает deep sleep» не доказано. Риск остаётся при незапуске post_boot, ошибке пути/SELinux или раннем выходе script. `bash -n` доказывает лишь синтаксис, не выполнение на Android sh. Проверять конечное значение sleep_disabled, состояние сервиса, suspend residency и wakelocks. Не удалять cmdline до проверки ранней загрузки.

`log:13692`, 02:06:07: suspend service не смог записать `zygote_kwl` в wake_unlock (`Invalid argument`). Одна операция не доказывает удержание wakelock; нужны kernel suspend stats. Батарейные измерения в log отсутствуют.

### 10.2. AVB и шифрование

`BoardConfig.mk:147-158` включает AVB, но `:148` задаёт vbmeta flags 3, а ключи vbmeta_system/recovery — test key из external/avb. Это подтверждённая конфигурация ослабленной цепочки проверки для custom build, **не** причина Wi-Fi/RKP сообщений. Значимость для production HIGH, для разработки зависит от выбранной модели доверия; реальный lock/verifiedbootstate неизвестен. Нельзя автоматически предлагать relock: с неподходящими ключами это опасно.

Минимальная будущая задача для релиза — согласовать модель подписи и убрать отключающие флаги только после отдельной проверки доверенной boot chain и recovery. В рамках этого аудита ни ключи, ни boot state не изменялись.

`rootdir/etc/fstab.qcom:44` содержит FBE + metadata encryption + wrappedkey_v0. Это не доказательство поддержки конкретным kernel/TEE, но факт успешного boot не даёт основания менять encryption flags ради RKP. `/persist` не formattable (`:45`), modem/bluetooth firmware mounts read-only (`:49-51`). Диагностика не запускала fsck/format/flash.

### 10.3. BPF и kernel compatibility — MEDIUM, гипотеза

`configs/props/product.prop:2` принудительно сообщает BPF loader версию `5.10.239`. Настоящее ядро здесь неизвестно. Если версия/набор backports отличаются от предполагаемых, gating eBPF может выбрать неподдерживаемую функциональность. Это конкретное значение для проверки, но не доказанный баг на данном kernel.

`log:3777,5090` и ещё два сообщения `Unable to parse binderfs stats`; это повод сопоставить формат binder stats с Android 16 ActivityManager, не доказанный отказ Binder IPC. Проверить uname/kernel config, backport BPF и binderfs, bpfloader logs; не удалять override без понимания причины его добавления.

### 10.4. Камера, сканер, сенсоры, USB и зарядка

* Камера подключается HIDL provider 2.4 + optional MiuiCamera, `device.mk:11,153-167`. Blob fixups добавляют camera shims, меняют RPC symbol versions и патчат camera postproc bytes. Без ELF нельзя проверить, к какой версии применён бинарный патч: `proprietary-files.txt` unpinned. Нужна фиксация контрольных сумм входных blobs и проверка точного preimage каждого fixup до дальнейшего использования. Отказ камеры или SIGSEGV в log не обнаружен; режимы камер не тестировались.
* Fingerprint service 2.3 Xiaomi (`device.mk:228`), Goodix/FPC permissions в init.xiaomi.rc. `log:13388` и далее GF_HAL пишет `GF_SUCCESS`, несмотря на E priority; это не hardware error. Enrollment/authentication не проверены.
* Sensors HIDL 1.0 и vendor sensor services; log `sensors-hal` с E priority передаёт pug_event (`:16944`), а не явно сообщает отказ. Ultrasound тесно связан с audio, поэтому proximity следует тестировать вместе с A01.
* USB AIDL QTI packages и внешний init USB (`device.mk:501-509`); локальные gadget properties согласованы по именам с init.target. VINTF fragments/реальный OTG/ADB/MTP не проверены.
* Health/thermal packages — `device.mk:243-245,499`; `proprietary-files.txt:1067-1102` содержит mi_thermald/thermal-engine/configs. Само одновременное наличие нескольких daemon не доказывает конфликт: нужны их действующие init/configs. Не отключать один из них по названию.
* `persist.vendor.pps.disallowed=1` и `persist.vendor.hvdcp_opti.disallowed=1` в vendor.prop требуют проверки с charger driver; они не доказывают ни отсутствие 67W, ни неисправность зарядки. Измерений зарядки/температур нет.
* XiaomiParts ThermalService регистрирует listener до создания mThermalUtils (`ThermalService.java:58,62`), исключения listener поглощаются (`:99`), отсутствует cleanup в onDestroy. Возможны пропуск первого события/устаревший listener; устойчивый runtime дефект не доказан, поэтому не приоритетнее D03. Service exported и защищён строкой `ThermalService` (`parts/AndroidManifest.xml:44-47`), локального объявления такой permission нет. Это требует проверки merged manifest/дизайна; не объявляется доказанным открытым доступом, поскольку неизвестная permission обычно не выдаётся произвольным приложениям.

## 11. Остальные значимые сообщения полного журнала

| Группа | Место | Вывод и недостающая проверка |
|---|---|---|
| Binder freeze / stats | `log:1014,3777,5090` | Проверить kernel binderfs/freezer integration; system_server FATAL не найден |
| System-fixed health permissions shell | `log:5525-5527` | Framework/permission reconciliation; DT hotword allowlist к этому не относится. Не снимать system-fixed для тишины |
| DeviceConfig `Parsing int failed for location_mode` | `log:1987,2238,2952,16636` | Неверный тип/значение runtime config или consumer; локального такого ключа не найдено. Источник runtime flags вне DT |
| SettingsToPropertiesMapper слишком длинное значение | `log:1658,2137,2757,16582` | Проблема сериализации DeviceConfig/property; не hardware HAL defect |
| Missing packages/providers, JobScheduler jobs | `log:1026-1028,2598-2608,3291-3293` | Часть совпадает с package setup/replacement; нужен повтор после обновления. Наличие stale job не повод выдавать привилегии |
| GMS Nearby missing component | `log:10109-10110,11080-11108,16340` | Несогласованность динамических GMS modules/APK; есть и после update. В DT нет компонента для правки |
| Calendar HTTP 410 Gone | `log:16196` и далее | Протокол синхронизации/устаревший sync token, вне DT; не ошибка модема |
| TradeInMode state -1 / missing persistent_data_block manager | `log:548,2529,5291` | Framework feature/backend; не основание добавлять раздел FRP или менять partition table |
| AdbDebuggingManager socket refused | `log:5779` | Один отказ control socket; не доказанный USB HAL failure, проверить после завершения startup |
| Surface transitions / libEGL no current context | `log:13755,13617` | SystemUI/application context usage; не доказанный отказ Adreno |
| ACDB `active device/stream not found` | `log:13577` и далее | Audio effect set parameters при lifecycle route; проверить вместе с A01 |
| Audio perf lock incorrect params | `log:13409,13572` | Конкретный failed hint в audio extension; perf implementation вне checkout, не доказывает отказ всего Power HAL |
| SatelliteController not initialized | `log:13933` и далее | Framework optional path, спутниковая поддержка не объявлена локально; не добавлять фиктивный HAL |
| QC-time-services с result=0 | `log:8147` и далее | Приоритет E не равен неудаче операции |

За весь журнал два `FATAL EXCEPTION`, ноль `Fatal signal`, ноль строк `avc: denied`. Это свойства данного logcat, не доказательство отсутствия kernel AVC/dmesg, native tombstones или более ранних boot failures. Большое число package/role/background сообщений связано с установкой и обновлением приложений, поэтому запись нельзя трактовать как установившийся многоминутный idle после завершения всех обновлений.

## 12. Выполненная безопасная валидация

| Проверка | Результат |
|---|---|
| Git status до аудита | Чистое дерево |
| XML parse | Все 48 XML разобраны ElementTree без ошибок |
| Локальные property keys | Один повтор с одинаковым значением; противоречащих значений между пятью prop-файлами не найдено |
| Overlay resources | Дубликатов одного resource type/name в одном overlay и одинаковом qualifier не найдено. Межпакетные ROM overlays и idmap не доступны |
| Shell syntax | `bash -n` для extract/setup и всех 7 rootdir shell scripts: exit 0. Это не Android mksh/runtime валидация |
| Blob list | 1042 записи, один duplicate destination для FM library |
| Init services | Дублирующихся service names среди локальных rc не найдено. Внешние init fragments могут добавлять/override сервисы |
| Mixer references | Base/common и sound_trigger paths разрешаются; base+static union без missing references; один duplicate path name |
| VINTF XML | Синтаксически корректен. `checkvintf` отсутствует; совместимость с Android 16 FCM не проверена |
| Soong/product inheritance | Локальные include traced; вычисление итоговых переменных невозможно без build/core, product entrypoint и внешних includes |
| ELF dependencies | Не проверены: ELF/vendor checkout отсутствует. Список blobs не доказывает ни наличие файлов, ни корректность DT_NEEDED |
| SELinux | Просмотр локальных правил/contexts и поиск запрещающих симптомов; policy compile/sepolicy-analyze не выполнены, полный policy отсутствует |
| Устройство | `adb` установлен, но `adb devices` не смог поднять daemon: sandbox запрещает socket/netlink; `/dev/bus/usb` отсутствует. Наличие или отсутствие подключённого телефона этим не установлено |
| Hardware tests | Не выполнялись; ни одна функция не объявляется проверенной на реальном устройстве |

Android build tools `checkvintf` и `aapt2` не найдены в PATH; `xmllint` и Python XML parser доступны. `envsetup.sh`/lunch не запускались, extract/setup scripts не выполнялись: они способны изменять vendor и не относятся к read-only диагностике.

Сервисы вроде `ssgqmigd`, `qvop-daemon`, `audioshell_service`, `init.mi.serial.sh` имеют локальные init-упоминания без очевидного локального blob producer. Но многие стандартные/source-built бинарники также не входят в proprietary list. Без общего QTI и installed-files нельзя корректно пометить эти сервисы missing. `mi-serial-sh` дополнительно ограничен условием `ro.product.device=elish`, не normal munch boot. Повторяющихся init exec failures этих сервисов в данном log не найдено.

## 13. Команды следующей проверки

Команды ниже **не выполнялись на телефоне**. Это план получения сведений, без flash/erase/root/remount/изменения критичных разделов. Некоторые dumps могут содержать личные сведения: хранить локально и обезличивать перед передачей; не публиковать сырые dumps. Не выполнять массовый `getprop`, если результаты планируется публиковать.

### Полное дерево AOSPA, когда оно будет доступно владельцу

```sh
# После штатного выбора существующего product через envsetup/lunch:
build/soong/soong_ui.bash --dumpvars-mode --vars='TARGET_PRODUCT TARGET_BUILD_VARIANT PLATFORM_VERSION PLATFORM_SDK_VERSION PRODUCT_SHIPPING_API_LEVEL BOARD_SHIPPING_API_LEVEL BOARD_VNDK_VERSION PRODUCT_TARGET_VNDK_VERSION TARGET_BOARD_PLATFORM TARGET_KERNEL_SOURCE TARGET_KERNEL_CONFIG DEVICE_MANIFEST_FILE DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE'
# PRODUCT_PACKAGES, PRODUCT_COPY_FILES, PRODUCT_VENDOR_PROPERTIES и namespaces
# выгрузить тем же dumpvars отдельно, чтобы проверить конечные merge/overrides.
# Уточнить поддерживаемые имена переменных в этой ветке AOSPA.
```

Проверить объединённые `out/target/product/munch/vendor/etc/vintf`, odm/system/product/system_ext fragments и все manifests из APEX. Запустить `checkvintf` с dirmap/props/kernel parameters **по help установленной версии**. Один локальный XML не является полной входной конфигурацией. Для libinit проверить `nm -C`/linker map на единственность `variants` и выбранный `xiaomi_munch.variant_lib`.

### Устройство: только чтение

```sh
adb shell getprop ro.build.version.release
adb shell getprop ro.build.version.sdk
adb shell getprop ro.product.first_api_level
adb shell getprop ro.board.first_api_level
adb shell getprop ro.vendor.api_level
adb shell getprop ro.board.api_level
adb shell getprop ro.vndk.version
adb shell uname -r
adb shell getenforce
adb shell lshal
adb shell service list
adb shell pm list features
adb shell dumpsys -l
adb shell cmd overlay list
adb shell cmd overlay lookup android android:string/db_default_journal_mode
adb shell cmd overlay lookup android android:string/db_default_sync_mode
adb shell cmd overlay lookup android android:string/db_wal_sync_mode
adb shell cmd overlay lookup com.android.wifi.resources com.android.wifi.resources:string/config_wifiSoftap2gChannelList
adb shell dumpsys wifi
adb shell dumpsys safety_center
adb shell dumpsys bluetooth_manager
adb shell dumpsys media.audio_flinger
adb shell dumpsys media.audio_policy
adb shell cat /proc/asound/pcm
adb shell cat /sys/module/lpm_levels/parameters/sleep_disabled
adb shell getprop init.svc.qcom-post-boot
```

Синтаксис `cmd overlay lookup`, service names и доступность sysfs могут отличаться; сначала `cmd overlay help`/`dumpsys -l`. Нельзя из отказа доступа к sysfs делать вывод о неисправности оборудования. `tinymix` **без аргументов изменения** — только если установлен и разрешён штатному shell. Не давать числовые аргументы controls.

По возможности сохранить read-only logs kernel/init через доступный владельцу безопасный способ. Не расширять SELinux и не включать root специально ради этого аудита. Сравнение fingerprints и attestation identity проводить локально; в отчёт вернуть только наличие различий, без персональных полей.

### Проверочные сценарии

1. После завершения GMS update — новый boot/idle log без установки приложений; отдельно package update scenario для WLC.
2. Wi-Fi off, scan-only, STA 2.4/5 GHz, SoftAP 2.4/5 GHz с клиентом; сравнить timestamps lifecycle и ошибок. Не форсировать DFS/страны.
3. Обычный TEE key -> attestation без ID -> разрешённый ID attestation; сохранить только статусы. RKP тестировать только при реально зарегистрированном IRPC.
4. Audio по маршрутам из A01, proximity во время звонка, Bluetooth A2DP/HFP и USB audio. Не запускать speaker calibration.
5. Экран выключен, без обновлений, сравнить suspend residency/wakelocks и расход на длинном интервале; не делать вывод по короткому logcat.
6. Сборка и merged-manifest/resource проверки будущих патчей. Для SQLite — только тестовая БД; для thermal — синтетические preferences, без изменения защитных daemon.

## 14. Что остаётся неизвестным

* Точный product entrypoint AOSPA и порядок наследования до/после device.mk, фактические build properties и Vendor API.
* Соответствие этого HEAD исходникам успешно запущенного образа; версия и дефконфиг реально собранного kernel.
* Содержимое общих QTI компонентов, Wi-Fi HAL/driver/firmware, final VINTF, Power HAL, modem/IMS blobs, GMS и PermissionController APK/APEX.
* Эффективное применение overlays и их приоритет относительно других ROM/vendor overlays.
* RKP в полном vendor image, поддержка отдельных attestation tags и provisioning identity TEE.
* Почему отсутствуют конкретные audio controls, применённые ACDB и корректность speaker protection.
* Фактическая работа Wi-Fi/SoftAP, NFC, камеры, сенсоров, fingerprint, зарядки и мобильной связи; показатели deep sleep.
* Полные boot/kernel logs, tombstones и SELinux audit. Отсутствие AVC в logcat не заменяет анализ policy/runtime.

Здесь нет оснований для перепрошивки модема, правок EFS/persist, удаления WLC, подмены сертификатов, выключения Safety Center, ослабления разрешений или добавления фиктивных HAL.

## 15. Приоритетный план действий

1. **Первый будущий патч DT:** убрать три небезопасных SQLite overrides D01, подтвердить штатные AOSPA defaults и effective resources. Это наиболее явный риск для данных, не зависящий от частоты logcat.
2. **До следующей сборки:** проверить и устранить двойное определение `variants` D02; зафиксировать product/Soong config и происхождение успешного image. Не связывать этот build-дефект с уже работающим TEE без доказательств.
3. **Следующий небольшой патч:** исправить валидацию шести thermal slots D03; проверить старые preferences. Затем удалить идентичные дубликаты D05, отделив неоднозначный audio path в самостоятельную проверку.
4. **Параллельно диагностике при наличии устройства:** effective Wi-Fi resources + тест с активным интерфейсом; TEE attestation без ID/с ID; mixer/PCM inventory. На основании результата выбрать минимальные изменения W02/W03/K02/A01. Пока эти vendor/framework исправления не готовы к безопасному применению.
5. **Отдельно на стороне ROM:** согласовать RoleController/PermissionController и Safety Center с GMS; проверить WLC после update и адаптировать его lifecycle, если несовместимость сохраняется. В данном DT доказанной точки исправления этих APK/Framework ошибок нет.
6. **Перед релизом:** review DAC/factory calibration trigger D06, AVB signing model, BPF/kernel compatibility, итоговый VINTF/ELF checks, длительные hardware и battery проверки. Не менять защищённые разделы и не relock bootloader в рамках этого плана.

**Результат текущего этапа:** создан только этот отчёт; исходники DT, firmware, SELinux, разрешения и данные устройства не исправлялись. Устранение ошибок и аппаратная работоспособность не заявляются без последующей проверки.

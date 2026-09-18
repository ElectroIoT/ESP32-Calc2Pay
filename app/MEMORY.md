# MEMORY.md — app/

## Current state (last updated: 2026-09-18)

- **Working build, debug APK sideloaded for testing.** Flutter project scaffolded with `flutter create` (package `calc2pay_companion`, org `com.calc2pay.oss`, Android + iOS platforms). `flutter analyze` clean, `flutter test` passes (1 smoke test), `flutter build apk --debug` produces a real installable APK — verified in this session, twice (once before and once after adding the BLE printer feature below).
- **Hardware milestone reached 2026-09-18: the physical e-paper display is now wired up and working** on the ESP32-S3 dev board firmware was flashed to (see `../firmware/MEMORY.md`). Keypad/printer are still not physically wired.
- **Added a second, independent BLE feature: connecting to a generic BLE thermal printer** (separate from the Calc2Pay ESP32 device) — see "BLE thermal printer feature" below.
- BLE library: **`flutter_blue_plus`** (chosen over `flutter_reactive_ble` — no spike needed, this was a reasonable default and nothing so far argues against it). `permission_handler` used for runtime BLE/location permission requests.
- Android manifest updated with `BLUETOOTH_SCAN`/`BLUETOOTH_CONNECT`/`ACCESS_FINE_LOCATION` (maxSdk 30) permissions and a `bluetooth_le` feature requirement (`android/app/src/main/AndroidManifest.xml`).
- **iOS Bluetooth usage-description strings NOT yet added** to `ios/Runner/Info.plist` — iOS build will need `NSBluetoothAlwaysUsageDescription` before BLE will work there; not done in this session (Android was the focus).
- **BLE GATT UUIDs are allocated by `../firmware/`** (`../firmware/include/ble_uuids.h`) and mirrored in `lib/ble/calc2pay_ble_uuids.dart`:
  - Service: `c2f5e000-3a9b-4b7e-8f21-6d1a2c3e4f50`
  - Merchant config characteristic (read/write, JSON: `{vpa, name, gst_percent, discount_percent}`): `c2f5e001-3a9b-4b7e-8f21-6d1a2c3e4f50`
  - Status characteristic (read/notify, JSON: `{fw_version, state}`): `c2f5e002-3a9b-4b7e-8f21-6d1a2c3e4f50`
  - Device ID characteristic (read-only, string — device's BLE MAC address): `c2f5e003-3a9b-4b7e-8f21-6d1a2c3e4f50`
  - Device advertises as `"Calc2Pay"`. BLE pairing/bonding security is not yet implemented firmware-side (open/unauthenticated) — the app currently connects without any pairing UI, matching that.
- **Verified end-to-end against real hardware (2026-09-18)**: connect → device status (firmware version + state) reads correctly → merchant config screen loads correctly → edited GST 0→18 → saved → re-read confirms it persisted on the ESP32. Three real bugs were found and fixed to get here (see "Bugs found and fixed" below) — two in the app, one in firmware.

## Source files and what each owns

| File | Owns |
|---|---|
| `lib/ble/calc2pay_ble_uuids.dart` | BLE GATT contract constants, mirrors firmware exactly |
| `lib/ble/calc2pay_ble_service.dart` | Singleton wrapping scan/connect/discover/read/write/notify against the Calc2Pay service specifically |
| `lib/ble/generic_ble_printer_service.dart` | Singleton for a **second, independent** BLE connection to a standalone thermal printer (not the Calc2Pay device) |
| `lib/models/merchant_config.dart` | JSON (de)serialization matching firmware's `MerchantConfig::toJson/fromJson` |
| `lib/models/device_status.dart` | JSON parsing matching firmware's status-characteristic payload |
| `lib/screens/scan_screen.dart` | Permission request, scan UI, connect action — the app's home/entry screen (Calc2Pay device only) |
| `lib/screens/device_home_screen.dart` | Read-only status display + nav to settings and to the BLE printer screen; disconnect action |
| `lib/screens/merchant_config_screen.dart` | Form to read/edit/write merchant config over BLE |
| `lib/screens/ble_printer_screen.dart` | Scan/connect/test-print flow for a standalone BLE thermal printer |
| `lib/main.dart` | App root, routes to `ScanScreen` |

## BLE thermal printer feature (added 2026-09-18)

The Calc2Pay hardware design wires its printer to the ESP32 over UART, not BLE (see `../hardware/04-SCHEMATIC-CONNECTIONS.md` Sheet 5) — so this is a **separate, independent BLE connection** for people who want to print from the phone directly to a standalone Bluetooth thermal printer (the common cheap "portable receipt printer" class), bypassing the Calc2Pay device entirely if they want to.

- `GenericBlePrinterService` scans **without a service-UUID filter** (unlike the Calc2Pay scan) because BLE thermal printer vendors don't share one standard GATT profile — each uses its own service/characteristic UUIDs.
- After connecting, it collects every characteristic with `WRITE` or `WRITE_WITHOUT_RESPONSE` and auto-selects the first one as the print target. This is a heuristic, not a guarantee: `BlePrinterScreen` surfaces a "no writable characteristic found" message if none exist (device doesn't support the assumed pattern) but does **not yet** offer a manual characteristic picker UI if auto-selection picks the wrong one among several candidates — `writableCharacteristics` is exposed on the service for that purpose, just not wired into the UI yet.
- `printText()`/`printRaw()` send plain UTF-8 bytes in ~180-byte chunks (many BLE printer modules have small MTU/buffer limits) — **not full ESC/POS command support** (no bold/alignment/QR/image printing), just plain text + line feeds. Good enough for a "test print" smoke test; a real receipt formatter would need proper ESC/POS command bytes for anything beyond plain text.
- This BLE connection is entirely independent of the Calc2Pay device's BLE connection — Android supports multiple simultaneous BLE GATT connections, so both can be connected at once in principle. **Not tested with both connected simultaneously.**
- Two Android devices can both be connected to the SAME BLE thermal printer at once, in theory. Not a concern for a single-phone POS use case, not tested.

## Bugs found and fixed against real hardware (2026-09-18)

1. **Android 12+ permission check always failed.** `requestBlePermissions()` (now in `lib/ble/ble_permissions.dart`) required `locationWhenInUse` to be granted alongside `bluetoothScan`/`bluetoothConnect`, but that permission is excluded via `maxSdkVersion="30"` in the manifest on Android 12+ and can never be granted there — silently blocking every scan. Fixed by only gating success on `bluetoothScan`/`bluetoothConnect`.
2. **Concurrent BLE GATT reads could hang forever.** `DeviceHomeScreen` fired `readStatus()` and `readDeviceId()` as two separate, unawaited `.then()` chains. BLE only allows one outstanding request per connection; issuing two at once risks a response being misrouted to the wrong pending request, leaving one hang indefinitely with neither a result nor an error. Fixed with a `_serialized()` FIFO queue in `Calc2PayBleService` that funnels every read/write through one queue, plus an 8s timeout so a genuine stall surfaces as a catchable `TimeoutException` instead of hanging silently.
3. **Trailing null byte broke JSON parsing.** BLE characteristic values on this stack were arriving with an extra `0x00` byte appended (odd-length payloads padded to even length — the JSON was 37 bytes, the value read back was 38). `jsonDecode` threw `FormatException: Unexpected character` on the trailing byte. Fixed by stripping trailing null bytes before decoding, applied to every read and notification.

Bug #3 was actually a symptom of a bigger firmware bug — see `../firmware/MEMORY.md`'s "Hard rule added after the setValue() bug": `NimBLECharacteristic::setValue(const char*)` was silently storing a raw memory address instead of copying string content, for characteristics where the value was computed dynamically (e.g. from `onWrite`/`onRead` callbacks). This was diagnosed by adding a temporary raw-hex-bytes dump to a `FormatException` message and reading it via `uiautomator dump` (no phone-side Flutter log capture was available in this session) — the bytes `40 80 ca 3f` decoded as a plausible ESP32-S3 SRAM address, not garbage, which pointed straight at a pointer-instead-of-string bug rather than a transient BLE glitch.

## Known gaps / simplifications made to get a first build compiling

- No reconnect/retry logic if a BLE connection drops mid-session — `DeviceHomeScreen` just shows whatever state it last had; a dropped connection isn't detected or surfaced yet.
- No pairing/bonding UI, matching firmware's current open/unauthenticated BLE (see `CLAUDE.md` rule 6 — don't imply more security than exists).
- iOS Bluetooth permission strings not added to `Info.plist` — Android is the only platform actually testable right now.
- No persistence of "last connected device" (Calc2Pay or the BLE printer) — every app launch starts at the scan screen. Fine for Rev-1, worth revisiting if it's annoying in practice.
- No app icon/branding customization — using Flutter's default generated icon set.
- BLE printer characteristic auto-selection has no manual override UI yet (see "BLE thermal printer feature" above).

## Open questions for whoever picks this up next

1. Whether to publish to Play Store/App Store at all in Rev-1, or ship as a sideloadable open-source APK only, given there's no backend/account system yet.
2. Reconnect UX: should the app auto-retry a dropped BLE connection, or always drop back to the scan screen?
3. App icon / branding — not addressed yet.
4. iOS testing — blocked on adding `Info.plist` Bluetooth strings and testing on an actual Mac/iOS toolchain (not available in this Windows dev environment).
5. Manual write-characteristic picker for the BLE printer screen, for printers where auto-selection picks the wrong characteristic.
6. Real ESC/POS command support for the BLE printer path (bold/alignment/QR/image), currently plain text only.

## If you are Claude, resuming this project fresh

Run `flutter pub get && flutter analyze && flutter test` from this folder first to confirm the build still passes before making changes. The Calc2Pay BLE contract is fixed by `../firmware/include/ble_uuids.h` — don't change `lib/ble/calc2pay_ble_uuids.dart` without checking there first. The BLE printer feature (`lib/ble/generic_ble_printer_service.dart`, `lib/screens/ble_printer_screen.dart`) is unrelated to that contract — it talks to a completely different, vendor-specific BLE device. The app has not yet been tested against a real Calc2Pay device or a real BLE printer on this machine (no phone was connected via adb in this session); a debug APK was sideloaded to the user's phone directly instead of `flutter run`.

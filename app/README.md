# Calc2Pay — Companion App

New, standalone, open-source Flutter mobile app that pairs with the Calc2Pay ESP32-S3 hardware over BLE. **Not related to, and does not share code with, the existing closed-source Flutter "Calc2Pay" billing app** (`D:\My Project\Android\Calc2Pay`) — see the top-level [`../MEMORY.md`](../MEMORY.md) for why that app isn't being reused.

## Status

**First working build exists.** A Flutter project (package `calc2pay_companion`, org `com.calc2pay.oss`) implements the full Rev-1 scope below. `flutter analyze` is clean, the widget smoke test passes, and `flutter build apk --debug` produces a real installable APK. **Never run against real Calc2Pay hardware yet** — see "Not yet verified" below.

## Implemented scope

- `lib/ble/calc2pay_ble_uuids.dart` — the BLE GATT contract, mirrored exactly from `../firmware/include/ble_uuids.h`
- `lib/ble/calc2pay_ble_service.dart` — `flutter_blue_plus`-based scan/connect/read/write/notify wrapper scoped to exactly the Calc2Pay service
- `lib/models/merchant_config.dart`, `lib/models/device_status.dart` — JSON models matching firmware's characteristic payloads
- `lib/screens/scan_screen.dart` — requests BLE/location permissions, scans for devices advertising the Calc2Pay service UUID, connects
- `lib/screens/device_home_screen.dart` — read-only device status (connection, firmware version, device ID) + entry point to settings
- `lib/screens/merchant_config_screen.dart` — reads current merchant config from the device, edits it, writes it back over BLE
- `lib/ble/generic_ble_printer_service.dart` + `lib/screens/ble_printer_screen.dart` — **separate feature**: connect the phone directly to a standalone BLE thermal printer (not the Calc2Pay device's own UART-wired printer), for people using a portable Bluetooth receipt printer instead of/alongside the hardware's built-in one. Broad scan (no fixed service UUID, since printer vendors differ), auto-picks a writable characteristic, and offers a plain-text test print.
- **No cloud backend, no user accounts, no transaction history sync** — device-local BLE configuration only, matching the hardware's Rev-1 scope (no verified payment integration yet, see `../hardware/01-DESIGN-REVIEW.md` §17)

## Not yet verified (do this before trusting the app against real hardware)

- Never connected to a real Calc2Pay device (firmware itself hasn't been flashed to hardware yet either — see `../firmware/MEMORY.md`).
- BLE pairing/bonding is not yet implemented firmware-side, so the app currently connects openly — don't add a false sense of security to the UI until firmware adds it.
- iOS BLE permission strings (`NSBluetoothAlwaysUsageDescription` in `ios/Runner/Info.plist`) have not been added yet — Android permissions are done (see `android/app/src/main/AndroidManifest.xml`), iOS testing is not.

## Stack

**Flutter**, using `flutter_blue_plus` for BLE (chosen over `flutter_reactive_ble` for this first build — no strong reason to switch unless a concrete limitation shows up) and `permission_handler` for runtime BLE/location permissions.

## Dependency on firmware

The BLE GATT service UUIDs and characteristic layout are defined by `../firmware/` and **are now allocated** — see `lib/ble/calc2pay_ble_uuids.dart` and `../firmware/include/ble_uuids.h`, which must always match exactly. If either changes, update both in the same commit and note it in both `MEMORY.md` files.

## How to build

```bash
cd app
flutter pub get
flutter analyze
flutter test
flutter build apk --debug     # or: flutter run, with a device/emulator connected
```

## Suggested next steps

1. Flash `../firmware/` to a real ESP32-S3 board (see `../firmware/README.md`) and connect this app to it for the first real end-to-end test.
2. Add iOS `Info.plist` Bluetooth usage-description strings if iOS support is needed.
3. Once firmware adds BLE bonding/pairing, update the connect flow here to handle the pairing prompt.

## License

To be decided alongside the hardware and firmware repos — apply the same open-source license (e.g. MIT or GPLv3) across all three so the project is consistently licensed end-to-end. Record the final choice in the top-level [`../README.md`](../README.md) once decided.

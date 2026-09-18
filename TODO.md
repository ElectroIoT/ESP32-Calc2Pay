# Calc2Pay — TODO / Roadmap

Living task list. Check items off as they're done; add new ones as they're discovered. See [FEATURES.md](FEATURES.md) for the full feature inventory and [MEMORY.md](MEMORY.md) for the reasoning behind decisions.

## 🔴 Immediate — close the loop on what's already built

- [ ] Debug why the app's device-status view shows firmware version `?` / state `unknown` even though the BLE read reports `GATT_SUCCESS` at the platform layer (see `app/MEMORY.md` — likely a JSON decode or characteristic-mapping issue, needs on-device Flutter log capture, not just ADB/logcat)
- [ ] Confirm merchant config round-trip: write UPI VPA/GST/discount from the app, power-cycle the ESP32, confirm it persisted in NVS
- [ ] Wire the physical 4×5 keypad to the dev board and confirm key presses reach the calculator engine
- [ ] Wire the 58mm thermal printer and confirm a real receipt prints correctly (baud rate is a best guess — verify against the actual printer)
- [ ] Confirm the QR code rendered on the e-paper actually scans correctly with a real UPI app
- [ ] Wire the buzzer and RGB status LED and confirm all feedback states (ready/BLE-connected/processing/success/error)

## 🟠 Near-term hardening

- [ ] Implement BLE pairing/bonding (currently open/unauthenticated) on both firmware and app sides
- [ ] Add reconnect/retry handling in the app when a BLE connection drops mid-session
- [ ] Add a manual write-characteristic picker in the BLE printer screen (auto-detection can pick the wrong one on some printers)
- [ ] Add iOS Bluetooth usage strings to `app/ios/Runner/Info.plist` and test on an actual iOS device/toolchain
- [ ] Persist "last connected device" so the app doesn't require a fresh scan every launch

## 🟡 Hardware bring-up → real PCB

- [ ] Measure the exact e-paper cable/connector pinout from the physical Waveshare module owned
- [ ] Measure the exact thermal printer connector type and confirm its baud rate/command set
- [ ] Confirm a buck converter part number against live JLCPCB/LCSC stock
- [ ] Build the actual EasyEDA schematic + PCB layout from the written spec in `hardware/`
- [ ] Order a small-batch prototype PCB and confirm DRC/ERC/Gerbers per `hardware/09-PRODUCTION-CHECKLIST.md`
- [ ] Assemble and bring up the first real Calc2Pay PCB (not a generic dev board)

## 🟢 Rev-2 candidates (not started, deliberately deferred)

- [ ] Battery + proper power-path management (not a bare TP4056 charger)
- [ ] RTC (RV-3028) for offline transaction timestamps
- [ ] microSD for transaction logs/config backup
- [ ] NFC for contactless triggering
- [ ] Verified/confirmed payment status via a backend or payment-provider integration (today, a displayed QR is never proof of payment — and must never be treated as such)
- [ ] Signed OTA firmware updates
- [ ] ESP32 Secure Boot + Flash Encryption

## 📱 App polish (lower priority, not blocking core functionality)

- [ ] Full ESC/POS command support for the standalone BLE printer path (bold, alignment, QR/image printing — currently plain text only)
- [ ] App icon / branding (currently using Flutter's default generated icon)
- [ ] Decide: publish to Play Store/App Store, or ship as a sideloadable open-source APK only
- [ ] Decide reconnect UX: auto-retry a dropped connection, or always drop back to the scan screen

## 📋 Project housekeeping

- [ ] Decide final repo structure: keep as one monorepo, or split `hardware/`, `firmware/`, `app/` into three separate public repos
- [ ] Set up basic CI (at minimum: `flutter analyze`/`flutter test` on the app, `platformio run` on firmware, on every push)

# MEMORY.md — firmware/

## Current state (last updated: 2026-09-18)

- **Working first build.** A PlatformIO project (`platformio.ini`, `include/`, `src/`) compiles successfully targeting a generic `esp32-s3-devkitc-1` board (Arduino framework, OPI PSRAM mode for the N8R8's octal PSRAM, 8MB flash partition table). Verified with `python -m platformio run` — SUCCESS, ~35KB RAM / ~586KB flash used.
- Framework: **Arduino via PlatformIO**, not ESP-IDF directly — chosen for library maturity (GxEPD2, NimBLE-Arduino, ArduinoJson, QRCode all have ready Arduino-ESP32 support). See `README.md` for the ESP-IDF migration note.
- **Flashed to real hardware and BLE-verified end-to-end.** Running on a physical ESP32-S3-DevKitC-1 (COM5, MAC `94:a9:90:2f:ee:a8`) with a physically wired e-paper display (confirmed rendering correctly). Keypad and thermal printer are not physically wired yet.
- **Fixed a real, reproduced firmware bug (2026-09-18)**: `NimBLECharacteristic::setValue()` called with a bare `const char*` (from `String::c_str()` or a string literal) was silently binding to a templated POD-storing overload instead of a string-copying one, storing a raw 4-byte pointer value as the characteristic's binary content instead of the actual string. This corrupted the merchant-config characteristic (confirmed via the app reading back `40 80 ca 3f` — a plausible ESP32-S3 SRAM address — instead of JSON). Fixed in `src/BleService.cpp` by explicitly constructing `std::string` for every `setValue()` call (mirroring the working `deviceIdChar` pattern, which already passed a `std::string`). Verified fixed: app now reads correct firmware version/state, and a full merchant-config write→read round-trip (GST 0→18) persisted correctly through NVS.
- **BLE GATT UUIDs are now allocated** (they were the first concrete cross-folder blocker noted previously) — see `include/ble_uuids.h`:
  - Service: `c2f5e000-3a9b-4b7e-8f21-6d1a2c3e4f50`
  - Merchant config char (R/W, JSON): `c2f5e001-...`
  - Status char (R/Notify, JSON): `c2f5e002-...`
  - Device ID char (R-only, string): `c2f5e003-...`
  - These are safe to change until `../app/` ships a build depending on them — if changed, update `../app/MEMORY.md` in the same commit.

## Source files and what each owns

| File | Owns |
|---|---|
| `include/pins.h` | GPIO pin numbers — mirrors `../hardware/03-GPIO-MAP.md` exactly |
| `include/ble_uuids.h` | BLE GATT contract shared with `../app/` |
| `src/Keypad.*` | Matrix scan + debounce, maps physical keys to a `Key` enum |
| `src/Calculator.*` | Running-total calculator logic, GST/discount math |
| `src/DisplayUI.*` | GxEPD2-based e-paper rendering, 3 screens (calculator/QR/printing) + error screen |
| `src/Printer.*` | UART thermal receipt printing |
| `src/Feedback.*` | RGB status LED + buzzer driver |
| `src/MerchantConfig.*` | NVS-persisted merchant settings, JSON (de)serialization |
| `src/BleService.*` | NimBLE GATT server wiring the above together over BLE |
| `src/main.cpp` | Top-level wiring: keypad events → calculator → display/printer/BLE/feedback |

## Known gaps / simplifications made to get a first build compiling

- `Calculator` has no operator precedence or parentheses — behaves like a physical calculator (single pending operation), matching the product's e-paper mockups in the original spec, not a math expression parser.
- `Printer` assumes 9600 baud and a plain-text command subset — **explicitly flagged VERIFY AGAINST DATASHEET** in the file header since this varies by printer module.
- `DisplayUI` assumes an SSD1680-based Waveshare 2.9" panel (`GxEPD2_290_BS`) — **explicitly flagged VERIFY** since Waveshare has shipped multiple controller revisions of the same nominal panel size.
- BLE pairing/bonding security (PIN confirmation, not "Just Works") is NOT yet implemented — `BleService::begin()` currently advertises openly. This is a known gap against the plan in `README.md`'s Security notes, not an oversight to silently accept — implement before treating this as production-ready.
- No OTA support yet (not required for Rev-1 bring-up).

## Hard rule added after the setValue() bug (2026-09-18)

**Never call `NimBLECharacteristic::setValue()` with a bare `const char*`.** Always wrap it in an explicit `std::string(...)` (see the `toStdString()` helper in `src/BleService.cpp`). A `const char*` argument can silently resolve to a templated POD-storing overload that stores the pointer's raw bytes instead of copying the string — this is exactly what happened to the merchant-config characteristic and would have looked correct at compile time with no warning.

## Open questions for whoever picks this up next

1. Real e-paper panel controller confirmation (see above).
2. Real thermal printer baud rate/command set confirmation.
3. BLE bonding/pairing security hardening (currently open/unauthenticated).
4. Whether to migrate to raw ESP-IDF later for OTA partitioning control (see `README.md`).

## If you are Claude, resuming this project fresh

Run `python -m platformio run` from this folder first to confirm the build still compiles before making changes (PlatformIO will auto-install matching toolchain/library versions from `platformio.ini` on a fresh clone — first run takes a few minutes to download). Read `CLAUDE.md` for the hard rules before touching `include/pins.h` or `include/ble_uuids.h`.

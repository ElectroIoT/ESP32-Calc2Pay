# Calc2Pay — Firmware

ESP32-S3 firmware for the Calc2Pay handheld calculator/payment terminal. Open source.

## Status

**First working build exists.** A PlatformIO project compiles clean (`pio run` — SUCCESS, ~11% RAM / ~18% flash used) implementing the full Rev-1 feature set below in software, targeting a generic ESP32-S3-DevKitC-1 for bring-up. Not yet flashed to real hardware or tested against a physical e-paper/printer/keypad — see "Not yet verified" below.

## Implemented scope

- `src/Keypad.cpp` — physical 4×5 keypad scan + software debounce (9 GPIO, active-low row scan, internal pull-ups on columns)
- `src/Calculator.cpp` — running-total calculator engine (single pending operator, like a physical calculator) with GST%/discount% applied to the total
- `src/DisplayUI.cpp` — e-paper rendering (GxEPD2, targets a Waveshare 2.9" SSD1680-based panel — **VERIFY** your exact panel controller) for the three screens: calculator, QR payment, printing status, plus an error screen
- `src/Printer.cpp` — thermal receipt printing over UART (plain-text, near-universal 58mm TTL command subset — **VERIFY** baud rate/command set against your exact printer)
- `src/BleService.cpp` — BLE GATT peripheral (NimBLE) exposing merchant config (read/write) and device status (read/notify); UUIDs allocated in `include/ble_uuids.h`
- `src/MerchantConfig.cpp` — merchant config (UPI VPA, business name, GST%, discount%) persisted in NVS via `Preferences`, JSON-serialized for BLE transfer
- `src/Feedback.cpp` — status RGB LED + buzzer (driven through a transistor, never direct from GPIO) for key press / QR generated / print started / print complete / error
- `src/main.cpp` — wires all of the above together per the product workflow (keypad → calculator → e-paper; QR key → UPI URI + QR display; PRINT key → receipt)

## Not yet verified (do this before trusting the firmware on real hardware)

- Never flashed to a physical ESP32-S3 board.
- No physical e-paper, thermal printer, or keypad has been connected/tested — `DisplayUI`'s exact GxEPD2 panel class and `Printer`'s baud rate are best-guess defaults marked `VERIFY AGAINST DATASHEET`.
- BLE GATT UUIDs in `include/ble_uuids.h` are newly allocated by this project (randomly generated, not yet used by any released app build) — safe to change until the companion app in `../app/` starts depending on them.

## Target framework

**Arduino framework via PlatformIO**, not raw ESP-IDF — chosen for this first build because the required libraries (GxEPD2 for e-paper, NimBLE-Arduino for BLE, ArduinoJson, the QRCode encoder) all have mature Arduino-ESP32 integrations and this got a working build compiling fastest. `README.md`'s earlier plan called out ESP-IDF as preferable long-term for OTA partitioning control; that migration is still open if/when signed OTA (Rev-2) is tackled — Arduino-ESP32 is not a dead end, just the pragmatic Rev-1 choice.

## GPIO source of truth

**`../hardware/03-GPIO-MAP.md` is authoritative.** Firmware pin definitions must exactly match that table. If a pin needs to change, update the hardware GPIO map first (and check it against the Octal-PSRAM/strapping-pin constraints documented there), then update firmware — never the other way around, since the firmware runs on physical silicon with fixed pin constraints, not the reverse.

## How to build

```bash
pip install platformio   # one-time, if the pio CLI isn't already installed
cd firmware
python -m platformio run                          # compile
python -m platformio run --target upload           # flash over USB (board connected)
python -m platformio device monitor                # serial console
```

## Suggested next steps (see `../MEMORY.md` at the project root for the full cross-project plan)

1. Flash to a real ESP32-S3-DevKitC-1 (or similar) with jumper-wired e-paper, printer, and a temporary keypad wired to the GPIOs in `include/pins.h` — this decouples firmware risk from custom PCB fabrication lead time.
2. Confirm the exact GxEPD2 panel class in `src/DisplayUI.h` matches your physical Waveshare module (swap if it isn't SSD1680-based) and validate the three e-paper screens render correctly.
3. Confirm the thermal printer's baud rate/command support in `src/Printer.cpp` against your physical module.
4. Validate BLE: connect from a generic BLE scanner app (e.g. nRF Connect) and read/write the merchant-config characteristic before building the real companion app against it.
5. Port GPIO pin definitions in `include/pins.h` to any changes made in `../hardware/03-GPIO-MAP.md` (should already match — keep them in sync) once the custom PCB arrives, and re-validate on real hardware.

## Security notes carried over from the hardware design review

Practical for Rev-1: unique device ID from the ESP32-S3's factory MAC/eFuse, BLE pairing with PIN/confirmation (avoid "Just Works" if the stack supports better), merchant config stored in NVS with basic obfuscation (not plaintext, not committed to source).

Deferred to Rev-2 (real cost, not worth doing before hardware is validated): ESP32 Secure Boot + Flash Encryption, signed OTA, full encrypted BLE application-layer payload beyond standard bonding/encryption.

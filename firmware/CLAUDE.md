# CLAUDE.md — firmware/

Instructions for Claude (or any AI agent) working in this folder. Read `MEMORY.md` in this folder first, then this file.

## What this folder is

The ESP32-S3 firmware source: a PlatformIO project (Arduino framework), flashed to and running on real hardware with BLE communication verified end-to-end against the companion app. See `MEMORY.md` for exactly what's implemented, what's simplified, and what's still open.

## Folder layout

```text
firmware/
  platformio.ini         ← board/framework/library config
  include/pins.h          ← GPIO map (mirrors ../hardware/03-GPIO-MAP.md)
  include/ble_uuids.h     ← BLE GATT contract shared with ../app/
  src/main.cpp            ← wires everything together
  src/Keypad.*, Calculator.*, DisplayUI.*, Printer.*, Feedback.*, MerchantConfig.*, BleService.*
```

Verify the build still compiles (`python -m platformio run`) before and after making changes.

## Hard rules

1. **GPIO pin definitions must come from `../hardware/03-GPIO-MAP.md`, verbatim.** Do not invent or guess a pin assignment. If a pin isn't in that table, it isn't assigned yet — go add it there first (and check it against the reserved-pin table in the same file) rather than picking one ad hoc in code.
2. **Do not use GPIO 26-37** for anything (Flash + Octal PSRAM reserved on the ESP32-S3-WROOM-1-N8R8 module this project targets) even if a compiler/SDK doesn't stop you — see `../hardware/01-DESIGN-REVIEW.md` §2 for why.
3. **Printer and e-paper are on separate buses** (UART vs SPI) per the hardware design — don't try to multiplex them onto shared pins to "save GPIO"; there's no GPIO shortage in the current map (one spare pin, GPIO48, is intentionally kept free).
4. **Displaying a QR code does not mean a payment succeeded.** Per the original product spec: never design firmware logic that treats "QR shown" or "QR scanned" as payment confirmation. Rev-1 has no payment-status feedback channel at all — the architecture should leave room for a future verified-payment integration (e.g., a status characteristic or webhook check) without requiring a rewrite, but must not fake or assume success in the meantime.
5. **Merchant configuration (UPI VPA, business info) must never be committed to source or logged in plaintext.** Store it in NVS; treat it as sensitive even though full flash encryption is deferred to Rev-2.
6. **Do not implement signed OTA, secure boot, or flash encryption in Rev-1** unless explicitly asked — these are deliberately deferred (see `README.md`'s Security notes) to avoid over-engineering before the hardware itself is validated.

7. **BLE GATT UUIDs in `include/ble_uuids.h` are now allocated and considered a stable contract with `../app/`.** Don't change them casually — if a change is genuinely needed, update `../app/MEMORY.md` in the same change.
8. **Only describe a feature as "working" or "verified" if it's actually been confirmed on real hardware.** `MEMORY.md`'s "Known gaps" section lists what's still unverified (panel controller, printer baud rate, BLE pairing security). Keep that section honest as gaps get closed.
9. **Never call `NimBLECharacteristic::setValue()` with a bare `const char*`.** Always wrap it in an explicit `std::string(...)`. A `const char*` can silently resolve to a templated POD-storing overload that stores the pointer's raw bytes instead of copying the string content — a real bug found and fixed in `src/BleService.cpp` on 2026-09-18 (see `MEMORY.md`). This applies to any future characteristic added to this codebase.

## When continuing implementation

- Confirm with the hardware folder (`../hardware/MEMORY.md`, "Open questions") whether the custom PCB has arrived yet. Until then, keep targeting a generic ESP32-S3 dev board with jumper-wired peripherals (current `platformio.ini` default), using the GPIO numbers in `include/pins.h` unchanged.
- Update `MEMORY.md`'s "Known gaps" and "Current state" sections as soon as something is verified on real hardware or a simplification is resolved — don't let it go stale.

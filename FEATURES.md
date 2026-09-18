# Calc2Pay — Feature List

Complete, itemized feature list across all three parts of the project. ✅ = implemented and verified on real hardware/build, 🧩 = implemented but not yet hardware/field-verified, 🗓️ = planned (Rev-2 or later), unless noted otherwise.

## Hardware (`hardware/`)

| Feature | Status | Notes |
|---|---|---|
| ESP32-S3-WROOM-1-N8R8 based design | ✅ | Native USB, Wi-Fi, BLE, 8MB Flash, 8MB Octal PSRAM |
| Corrected GPIO map (fixes Octal-PSRAM pin conflict) | ✅ | See `hardware/01-DESIGN-REVIEW.md` §2/§5 |
| 2.9" Waveshare e-paper interface (SPI) | ✅ | Wired and confirmed working on real hardware |
| 4×5 physical matrix keypad interface | 🧩 | GPIO map defined, not yet physically wired |
| 58mm thermal printer interface (UART) | 🧩 | GPIO map + dedicated 5V power path defined, not yet physically wired |
| Dedicated printer 5V power rail (separate from 3.3V logic) | 🧩 | Designed, not yet built/tested |
| Buck converter power design (not LDO) | 🧩 | Chosen for thermal margin under Wi-Fi/BLE peak current |
| USB-C power + native USB programming | ✅ | Used to flash and power the dev board in this session |
| Status RGB LED + buzzer driver circuit | 🧩 | Designed, not yet physically wired |
| I2C + debug expansion headers | 🧩 | Designed for future use |
| Full BOM with sourcing notes | ✅ | `hardware/06-BOM.md` |
| PCB placement/routing rules, antenna keepout | ✅ | `hardware/07-PCB-LAYOUT-ROUTING.md` |
| EasyEDA build guide | ✅ | `hardware/08-EASYEDA-GUIDE.md` |
| Google Material–style GPIO wiring diagram (SVG) | ✅ | `hardware/gpio-wiring-diagram.svg` |
| Custom EasyEDA schematic/PCB files, Gerbers | 🗓️ | Not started — written spec only so far |
| Battery + power-path management | 🗓️ | Rev-2 |
| RTC (RV-3028) for timestamps | 🗓️ | Rev-2 |
| microSD for logs/transactions | 🗓️ | Rev-2 |
| NFC | 🗓️ | Rev-2 |
| Verified/confirmed payment status (beyond "QR shown") | 🗓️ | Requires a backend/payment-provider integration, deliberately out of scope for Rev-1 |

## Firmware (`firmware/`)

| Feature | Status | Notes |
|---|---|---|
| Matrix keypad scan + software debounce | 🧩 | Compiles; not tested against physical keypad yet |
| Running-total calculator engine (+, −, ×, ÷) | 🧩 | Single pending operator, matches physical-calculator behavior |
| GST % and discount % applied to totals | 🧩 | Configurable via BLE merchant config |
| E-paper rendering: calculator / QR / printing / error screens | ✅ | Confirmed working on real e-paper hardware |
| UPI payment URI builder (`upi://pay?...`) | 🧩 | Logic implemented, not field-tested against a real UPI app scan yet |
| QR code generation and e-paper rendering | 🧩 | Implemented via QRCode library, not yet visually confirmed on hardware |
| Thermal receipt printing over UART | 🧩 | Implemented, not yet tested against a physical printer |
| BLE GATT peripheral (merchant config + status) | ✅ | Confirmed: real Android phone connects, reads device ID successfully |
| Allocated, documented BLE UUID contract | ✅ | Shared exactly between firmware and app |
| NVS-persisted merchant configuration | 🧩 | Implemented, not yet round-tripped from a real app write |
| Buzzer feedback (key press / QR / print / error) | 🧩 | Driver circuit + firmware written, not yet physically wired |
| RGB status LED (ready/BLE-connected/processing/success/error) | 🧩 | Driver circuit + firmware written, not yet physically wired |
| BLE pairing/bonding security | 🗓️ | Currently open/unauthenticated — flagged as a gap to close before production use |
| Signed OTA updates | 🗓️ | Rev-2 |
| Secure Boot + Flash Encryption | 🗓️ | Rev-2 |

## Companion App (`app/`)

| Feature | Status | Notes |
|---|---|---|
| BLE scan + connect to the Calc2Pay device | ✅ | Confirmed: connects to a real ESP32-S3 device advertising as "Calc2Pay" |
| Runtime BLE/location permission handling (Android 12+ correct) | ✅ | Fixed a real bug this session where a legacy permission blocked scanning on modern Android |
| Device status display (connection, firmware version, device ID) | ✅ | Confirmed correct (firmware version, state, device ID) after fixing a firmware-side BLE characteristic corruption bug |
| Merchant settings screen (UPI VPA, business name, GST %, discount %) | ✅ | Confirmed full round-trip: edited GST from the app, saved, re-read from device — persisted correctly |
| **Standalone BLE thermal printer connector** (separate from the Calc2Pay device) | 🧩 | Broad BLE scan, heuristic write-characteristic detection, plain-text test print — for portable Bluetooth receipt printers |
| Disconnect / reconnect flow | 🧩 | Basic flow implemented; no auto-reconnect on dropped connection yet |
| iOS support | 🗓️ | Missing `Info.plist` Bluetooth usage strings; untested (no Mac/iOS toolchain available) |
| Cloud backend / accounts / transaction history | 🗓️ | Deliberately out of scope — device-local BLE configuration only |
| Manual BLE-printer characteristic picker | 🗓️ | Auto-detection only for now |
| Full ESC/POS support for the standalone BLE printer (bold, alignment, QR/image printing) | 🗓️ | Plain text + line feeds only today |

---

For what's actively being worked on next, see [TODO.md](TODO.md). For the full reasoning behind design decisions, see each folder's own `MEMORY.md`.

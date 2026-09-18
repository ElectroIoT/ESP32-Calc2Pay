# Calc2Pay — ESP32-S3 Smart Payment Calculator

### Calculate • Pay • Print

**An open-source, handheld payment calculator** — a physical calculator keypad, an e-paper display, instant UPI QR codes, and a built-in thermal receipt printer, all driven by an ESP32-S3 and paired with a BLE companion app. Designed for small shops, street vendors, and anyone who wants "calculator meets UPI QR meets receipt printer" in one pocket-sized, buildable, open device.

![Platform](https://img.shields.io/badge/MCU-ESP32--S3-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Status](https://img.shields.io/badge/status-active%20development-yellow)
![Open Source](https://img.shields.io/badge/hardware%20%2B%20firmware%20%2B%20app-open%20source-orange)

📋 [**Full feature list**](FEATURES.md) · ✅ [**Roadmap / TODO**](TODO.md) · 🧠 [**Project memory / deep context**](MEMORY.md)

---

## Why Calc2Pay?

Every small merchant already owns a calculator. Calc2Pay turns that everyday habit into a payment flow: **type the bill like you always have, hit one button, and a UPI QR appears on-screen for the customer to scan — then print the receipt.** No phone required at the counter, no app to fumble with mid-sale. The companion app exists for setup, not for every transaction.

## How it works

```text
  Physical keypad            ESP32-S3 + e-paper           Customer's phone
 ┌───────────────┐          ┌─────────────────────┐      ┌───────────────┐
 │ 7 8 9 ÷  CLR  │  type    │   1250 + 350         │      │               │
 │ 4 5 6 x  DEL  │ ───────► │              ₹1600.00│      │               │
 │ 1 2 3 -  QR   │  press   │   TOTAL      ₹1600.00│      │  Scans QR →   │
 │ 0 . = +  PRINT│   QR     └─────────┬───────────┘      │  pays via UPI │
 └───────────────┘                    │ QR shown          └───────────────┘
                                       ▼
                              ┌─────────────────┐
                              │   SCAN TO PAY    │
                              │   [QR CODE]      │
                              │   ₹1,600.00       │
                              └────────┬──────────┘
                                       │ press PRINT
                                       ▼
                              🧾 Thermal receipt printed
```

## What's in this repo

This is a **monorepo**: hardware design, firmware, and a mobile app, built together and kept in sync.

| Folder | What it is | Status |
|---|---|---|
| [`hardware/`](hardware/) | Full PCB design spec for the ESP32-S3-WROOM-1-N8R8 based board: GPIO map, schematic, power tree, BOM, PCB layout rules, EasyEDA build guide | 📐 Design complete on paper, e-paper bring-up **verified on real hardware** |
| [`firmware/`](firmware/) | ESP32-S3 firmware (PlatformIO/Arduino): calculator engine, e-paper UI, QR generation, thermal printing, BLE GATT service, NVS merchant config | ⚡ **Flashed and running on real hardware** |
| [`app/`](app/) | Open-source Flutter companion app: BLE pairing, merchant settings (UPI ID, GST, discount), device status, plus a separate standalone BLE thermal printer connector | 📱 **Installed and BLE-connected to real hardware** |

Each folder carries its own `README.md` (how to build it), `CLAUDE.md` (contributor/AI-agent rules), and `MEMORY.md` (current state and decisions) — read those before diving into a specific part.

## Highlights

- 🧮 **Real physical keypad** — no touchscreen calculator gimmick, just type like you always have
- 🖥️ **E-paper display** — sunlight-readable, low-power, shows exactly what a shopkeeper needs: amount, QR, print status
- 💸 **Instant UPI QR generation** — one button turns a total into a scannable payment request
- 🧾 **Built-in thermal printer support** — hardware-wired receipt printing, no phone needed
- 📶 **BLE companion app** — configure your UPI ID, business name, GST %, and discount % from your phone
- 🖨️ **Bonus: standalone BLE thermal printer support in the app** — connect a portable Bluetooth receipt printer straight from your phone, independent of the Calc2Pay hardware
- 🛠️ **Fully open source** — hardware schematics, firmware, and app, all buildable and modifiable
- 🚫 **No overengineering** — Rev-1 deliberately skips battery/RTC/microSD/NFC to stay simple, reliable, and easy to build; see [`hardware/01-DESIGN-REVIEW.md`](hardware/01-DESIGN-REVIEW.md)

See [FEATURES.md](FEATURES.md) for the complete, itemized feature list across hardware, firmware, and app.

## Getting started

- **Building the hardware?** Start at [`hardware/README.md`](hardware/README.md).
- **Flashing firmware?** Start at [`firmware/README.md`](firmware/README.md) — PlatformIO project, builds with `python -m platformio run`.
- **Running the app?** Start at [`app/README.md`](app/README.md) — Flutter project, builds with `flutter build apk`.
- **New contributor or AI agent picking this up cold?** Read [`MEMORY.md`](MEMORY.md) first — it's written specifically so anyone (human or AI) can clone this repo and understand exactly where things stand.

## Design philosophy

**Simplicity + Reliability + Expandability + Manufacturability** — not maximum features. Every hardware/firmware decision is documented with its reasoning in [`hardware/01-DESIGN-REVIEW.md`](hardware/01-DESIGN-REVIEW.md), including a corrected GPIO map (the original design brief had a critical Octal-PSRAM pin conflict that's now fixed).

## License

MIT — see [`LICENSE`](LICENSE). Applies to hardware design files, firmware, and the app in this repository.

## Not to be confused with

There's a separate, closed-source Flutter billing app also called "Calc2Pay" elsewhere in the author's projects — that app has nothing to do with this hardware, and this repository's companion app is a from-scratch, independent, open-source project. See [`MEMORY.md`](MEMORY.md) for details.

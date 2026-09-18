# MEMORY.md — project root

Full current-state summary for the Calc2Pay project. If you are Claude (or any agent) opening this repository with no prior conversation context — including after someone else clones this repo and asks you to "understand this project" or "continue this" — **read this file in full before doing anything else**, then drill into the relevant subfolder's own `README.md` / `CLAUDE.md` / `MEMORY.md`.

## What Calc2Pay is

A handheld, open-source calculator/payment terminal: physical keypad, 2.9" e-paper display, UPI QR code generation, 58mm thermal receipt printer, BLE connectivity to a companion phone app — built around an ESP32-S3-WROOM-1-N8R8 module. Tagline: "Calculate • Pay • Print." Full product concept and workflow: `README.md` and `hardware/02-ARCHITECTURE.md`.

## Repository state (last updated: 2026-09-18)

| Folder | State |
|---|---|
| `hardware/` | Full written spec (9 documents) exists and is internally consistent. GPIO map has been corrected from the original design brief (see below). No EasyEDA project, no PCB layout, no Gerbers, no physical prototype yet. |
| `firmware/` | **Flashed to real hardware.** PlatformIO/Arduino project compiles clean and has been flashed to a physical ESP32-S3 dev board (native USB, COM port, MAC confirmed via esptool). **The e-paper display is now physically wired and confirmed working** as of 2026-09-18. Keypad and thermal printer are not physically wired yet — see `firmware/MEMORY.md` "Known gaps." |
| `app/` | **Verified end-to-end against real hardware.** Flutter project (`calc2pay_companion`) installed on a real Android phone, connected to the flashed ESP32-S3 over BLE, and confirmed working: device status reads correctly, merchant config (UPI VPA/GST/discount) reads, edits, saves, and persists correctly on the device. Three real bugs were found and fixed to get here (2 app-side, 1 firmware-side) — see `app/MEMORY.md` and `firmware/MEMORY.md`. |

Hardware fabrication (real custom PCB) has not happened yet — everything above is verified on a generic ESP32-S3 dev board, not the final Calc2Pay PCB.

## The most important fact to know before touching anything

The original hardware brief proposed using GPIO35, 36, 37 on the ESP32-S3-WROOM-1-**N8R8** module for peripherals (user button, status LED, future expansion). **This is wrong** — the N8R8 variant uses Octal PSRAM, which is wired internally to GPIO33–37 (in addition to the Flash pins on GPIO26–32 that every WROOM-1 variant reserves). Those pins are not exposed externally on this module and cannot be used for anything else. This was caught and corrected during design review; the corrected, authoritative pin map is `hardware/03-GPIO-MAP.md`. Full reasoning: `hardware/01-DESIGN-REVIEW.md` §2/§5.

**Any code, schematic, or discussion that references GPIO35/36/37 as available on this module is wrong and predates the correction — do not trust it.**

## Why there are two "Calc2Pay" projects and how to tell them apart

There is an **unrelated, pre-existing, closed-source Flutter app** called Calc2Pay at `D:\My Project\Android\Calc2Pay` (a billing/payment-QR phone app, not connected to any hardware, all 13 of its phases already complete). This repository's Calc2Pay is a **separate, new, open-source project**: custom hardware + firmware + a brand-new companion app. They share a name by branding coincidence, nothing else.

- If someone asks to "connect this to Calc2Pay" or "make Calc2Pay work with this hardware," they almost certainly mean building the new companion app in `app/`, not extending the old Flutter app. The old app's codebase, package name, and Play Store listing must not be reused or depended upon — see `app/CLAUDE.md` rule 1.
- If genuinely ambiguous which "Calc2Pay" is meant in a given request, ask rather than guessing, since they are different products with different licensing (closed vs. open source) and different tech stacks.

## Cross-folder dependencies to keep in sync

1. **Hardware → Firmware**: every GPIO firmware touches must exist in `hardware/03-GPIO-MAP.md`. `firmware/include/pins.h` currently mirrors it exactly — keep it that way.
2. **Firmware → App**: BLE GATT service/characteristic UUIDs are owned by firmware and **are now allocated** in `firmware/include/ble_uuids.h` (service `c2f5e000-...`, merchant-config/status/device-id characteristics `c2f5e001/2/3-...`, all sharing the `3a9b-4b7e-8f21-6d1a2c3e4f50` suffix). `app/MEMORY.md` has the full table — this blocker is resolved, `app/` can start real BLE work against it (or against the firmware itself, once flashed).
3. **Hardware → Everything**: physical connector pinouts for the e-paper and thermal printer depend on the exact physical modules in hand and have not yet been measured/documented anywhere in this repo — flagged as open questions in `hardware/MEMORY.md`, and firmware's `DisplayUI`/`Printer` modules use flagged best-guess defaults pending that verification.

## Open questions across the whole project (see each folder's MEMORY.md for folder-specific detail)

1. Thermal-printer connector/baud-rate specifics still need physical wiring + testing (e-paper is now done — see above).
2. Buck converter part number — needs live stock verification (hardware only, doesn't block firmware/app; not relevant to the current bare-dev-board bring-up either).
3. ~~The app has never connected to the real flashed ESP32 board~~ — **done and verified 2026-09-18**: BLE connect, device status, and full merchant-config read/write/persist round-trip all confirmed working, after fixing 3 real bugs (see `app/MEMORY.md` and `firmware/MEMORY.md`).
4. BLE pairing/bonding security (currently open/unauthenticated in firmware, matched by no pairing UI in the app) — needs hardening before treating the BLE link as trustworthy.
5. ~~Final open-source license~~ — **decided: MIT**, see `LICENSE` at repo root (2026-09-18).
6. Repo structure: **decided to ship as one monorepo** for now (pushed to `https://github.com/ElectroIoT/ESP32-Calc2Pay`, 2026-09-18) — can still be split into separate repos later if that becomes preferable.
7. iOS support for `app/` is incomplete (missing `Info.plist` Bluetooth usage strings, untested — no Mac/iOS toolchain in this dev environment).
8. Keypad and thermal printer still need to be physically wired to the dev board for full end-to-end testing (currently only the e-paper is connected).

## Standing rule added after the BLE debugging session (2026-09-18)

**Never call `NimBLECharacteristic::setValue()` with a bare `const char*` in firmware.** Always wrap it in an explicit `std::string(...)`. A real bug (root cause of a wider BLE data-corruption issue) was found and fixed where this pattern silently stored a raw memory address instead of the intended string — see `firmware/MEMORY.md` and `firmware/CLAUDE.md` rule 9 for the full story.

## Suggested next step

Wire up the physical keypad and thermal printer to the dev board to close out full hardware bring-up — BLE communication between the app and ESP32 is now fully verified, so the remaining gap is purely physical peripherals, not software.

# CLAUDE.md — project root

Instructions for Claude (or any AI agent) working anywhere in this repository. Read `MEMORY.md` in this folder first — it has the full current-state summary. This file has the standing rules.

## What this repository is

A monorepo for the **Calc2Pay** open-source ESP32-S3 payment calculator: `hardware/` (PCB design docs), `firmware/` (ESP32-S3 code, not started), `app/` (Flutter BLE companion app, not started). See `README.md` for the layout and product concept.

## Standing rules for the whole repo

1. **This is a different project from the closed-source Flutter "Calc2Pay" billing app** at `D:\My Project\Android\Calc2Pay` on the original author's machine. If you're told to "connect this to Calc2Pay" or similar, that almost certainly means the app in `app/` in *this* repo, not that unrelated external app — do not import code, package names, or assets from it. If genuinely unsure which is meant, ask.
2. **`hardware/03-GPIO-MAP.md` is the single source of truth for every GPIO pin.** Firmware code must match it exactly. Never assign a GPIO in firmware that isn't in that table, and never change a pin in that table without checking `hardware/01-DESIGN-REVIEW.md`'s reserved-pin reasoning (Flash/Octal-PSRAM/strapping/USB constraints on the ESP32-S3-WROOM-1-N8R8 module).
3. **Don't overengineer.** This project's own design brief explicitly rejects adding ICs/features "because they're technically possible" — no keypad controller, no separate BLE IC, no USB-UART bridge, no battery/RTC/microSD/NFC in Rev-1. If a task seems to require one of these, treat that as a signal to re-read `hardware/01-DESIGN-REVIEW.md` before proceeding, not to just add the part.
4. **A QR code being displayed or scanned is never proof of payment.** Rev-1 hardware has no payment-confirmation channel. Don't write firmware or app logic (or documentation) that implies otherwise.
5. **Keep the three sub-projects loosely coupled but consistent.** Hardware defines the pins; firmware defines the BLE contract (GATT UUIDs/characteristics); the app consumes that contract. Changing one of these without checking the dependent folder's `MEMORY.md` will desync them — always check.
6. **Update the relevant `MEMORY.md`(s) after any substantive change** — new code committed, a decision reversed, a GPIO reassigned, a UUID allocated. This repo is meant to be picked up cold by a stranger (or a fresh Claude session with no prior conversation) after a `git clone`; the `MEMORY.md` files are how that works. Stale memory files are worse than none — keep them accurate, not just present.
7. **All three sub-projects are meant to be open source.** Don't introduce a dependency (code, library, or asset) with a license incompatible with that goal, and don't copy from private/closed repos.

## Working across folders

- If a task touches both hardware and firmware (e.g., "add a new button"), update `hardware/03-GPIO-MAP.md` and `hardware/04-SCHEMATIC-CONNECTIONS.md` first, then `firmware/` to match — never the reverse, since firmware runs on fixed silicon/board pins.
- If a task touches both firmware and app (e.g., "add a new BLE characteristic"), allocate/document it in `firmware/MEMORY.md` first, then implement in `app/`.
- Don't let `hardware/`, `firmware/`, and `app/` end up as separate git repos without checking with the user first — see `README.md`'s "Open source" section; the current plan doesn't specify a final split, only that each is independently open-sourceable.

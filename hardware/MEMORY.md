# MEMORY.md — hardware/

Running log of decisions and state for the hardware design. Read this first if you're picking up this repo cold (including after a fresh `git clone`).

## Current state (last updated: 2026-09-18)

- Design phase only. All 9 spec documents (`01`–`09`) are written and internally consistent with each other and with `03-GPIO-MAP.md` as the single source of truth for pin assignments.
- No EasyEDA project, no schematic capture, no PCB layout, no Gerbers exist yet.
- No physical prototype exists yet.

## Key decisions and why (don't re-litigate these without reading the reasoning first)

- **MCU**: ESP32-S3-WROOM-1-N8R8, native USB, no USB-UART bridge, no keypad controller IC, no separate BLE IC. Rationale: `01-DESIGN-REVIEW.md` §1, §11.
- **GPIO map corrected from the original spec**: original spec proposed GPIO35/36/37 for USER BUTTON/STATUS LED/FUTURE. These are internally reserved for Octal PSRAM on the N8R8 module and don't exist externally. Moved those functions to GPIO38-41/47/48. Full table: `03-GPIO-MAP.md`. This was the single most important correction made during design review — see `01-DESIGN-REVIEW.md` §2/§5.
- **Regulator**: buck converter (not LDO) for 5V→3.3V, because an LDO would dissipate ~1W at Wi-Fi peak current in a sealed enclosure. Exact part number still needs verification against live stock (`06-BOM.md`, ref U2) — treat "TLV62569" / "AP63203" as reference candidates only, not locked.
- **Keypad**: direct GPIO matrix scan, no diodes in Rev-1 (ghosting judged cosmetic for a calculator use pattern), optional diode footprints reserved for Rev-2 if real-world testing shows it's needed. Rationale: `01-DESIGN-REVIEW.md` §6.
- **Power**: printer runs off a dedicated 5V rail with its own polyfuse and bulk capacitor, separate from the 3.3V logic rail and its own polyfuse. This is non-negotiable for reliability (thermal printer current spikes must not brown out the ESP32-S3). Rationale + exact values: `05-POWER-TREE.md`.
- **Layer count**: 2-layer PCB judged sufficient; 4-layer only if prototype EMI testing later shows a real problem. Rationale: `07-PCB-LAYOUT-ROUTING.md`.
- **Scope discipline**: battery, RTC, microSD, NFC all deliberately deferred to Rev-2, not stubbed into Rev-1's BOM/PCB. Rationale: `01-DESIGN-REVIEW.md` §11, `06-BOM.md` "Optional/Future" section.

## Open questions / things a future session (human or Claude) must resolve before ordering a PCB

1. Exact e-paper cable/connector pinout (physical module in hand — not yet measured/documented here).
2. Exact thermal printer connector type (physical module in hand — not yet measured/documented here).
3. Confirmed buck converter part number with live stock check.
4. Confirmed ESP32-S3-WROOM-1-N8R8 datasheet revision used for final sign-off.
5. Physical dimensions of enclosure — needed before board outline can be finalized (`07-PCB-LAYOUT-ROUTING.md` intentionally leaves this open per the original spec's own instruction not to guess).

## If you are Claude, resuming this project fresh (e.g. after a repo clone with no prior conversation memory)

Read `CLAUDE.md` in this folder for the hard rules, then `01-DESIGN-REVIEW.md` for the reasoning, then `03-GPIO-MAP.md` as the pin-assignment source of truth. Do not regenerate the GPIO map from the original raw spec in the top-level project brief (if you find one) without cross-checking it against the corrections already made here — the raw brief contains the original N8R8/Octal-PSRAM GPIO bug.

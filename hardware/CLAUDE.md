# CLAUDE.md — hardware/

Instructions for Claude (or any AI agent) working in this folder. Read `MEMORY.md` in this folder first, then this file, before touching any spec.

## What this folder is

Written hardware specification only — no EasyEDA project files, no Gerbers, no schematic source live here yet (as of the last update to `MEMORY.md`). The 9 numbered markdown files ARE the design; EasyEDA files, once created, should be added under `hardware/easyeda/` and Gerber exports under `hardware/gerbers/`, each new subfolder documented in this file's "Folder layout" section below when it's created.

## Folder layout (update this list whenever a new subfolder is added)

```text
hardware/
  README.md, CLAUDE.md, MEMORY.md   ← this doc set
  01-DESIGN-REVIEW.md ... 09-PRODUCTION-CHECKLIST.md   ← the specification
  easyeda/       ← (not yet created) EasyEDA project export/source, once schematic capture starts
  gerbers/       ← (not yet created) fabrication output, once a board revision is ordered
```

## Hard rules — do not violate these without re-deriving the reason

1. **Never assign GPIO 26–37 to any peripheral.** GPIO26-32 are Flash pins on every ESP32-S3-WROOM-1 variant; GPIO33-37 are Octal PSRAM pins on the **N8R8** variant specifically (see `01-DESIGN-REVIEW.md` §2 — this was the original spec's critical bug). If the module part number ever changes (e.g., to a non-PSRAM or quad-PSRAM variant), re-verify this constraint against that module's datasheet before reusing this GPIO map.
2. **GPIO 0, 3, 45, 46 are strapping pins** — treat exactly as documented in `03-GPIO-MAP.md`'s reserved table. Don't add pull resistors or peripherals to them.
3. **GPIO 19/20 are fixed to native USB** by silicon, not reassignable.
4. **The printer's 5V rail and the 3.3V logic rail must stay electrically separate** (separate polyfuses, separate bulk caps) — this is a reliability requirement from the original spec, not a preference. Don't simplify it away to save BOM cost.
5. **No keypad controller IC, no separate BLE IC, no USB-UART bridge** — deliberate simplicity choices per `01-DESIGN-REVIEW.md` §1/§11. Don't add one unless a concrete GPIO or timing constraint forces it, and if you do, document why in `01-DESIGN-REVIEW.md`, don't just change the BOM silently.
6. **Don't add Rev-2 components (battery, RTC, microSD, NFC) to the Rev-1 BOM or PCB.** Rev-2 gets its own design pass. Reserved-but-unpopulated footprints are fine only where `07-PCB-LAYOUT-ROUTING.md` already says so.
7. Any spec value marked `VERIFY AGAINST DATASHEET` must actually be verified (against the physical module or its datasheet) before it's treated as final — don't silently drop the caveat when editing these files later.

## When asked to change the design

- If a GPIO reassignment is requested, cross-check the new pin against the reserved-pin table in `03-GPIO-MAP.md` before proposing it, and update both `03-GPIO-MAP.md` and `04-SCHEMATIC-CONNECTIONS.md` together — they must stay consistent.
- If a component is proposed for removal/addition, check `01-DESIGN-REVIEW.md` and `06-BOM.md` for the stated reasoning first, so you don't reintroduce something that was deliberately rejected (or vice versa).
- Firmware GPIO usage (in `../firmware/`) must always match `03-GPIO-MAP.md` exactly — if you change one, update the other and note it in both folders' `MEMORY.md`.

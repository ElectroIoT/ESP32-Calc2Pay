# Calc2Pay — Hardware

Open-source PCB design for the Calc2Pay handheld calculator/payment terminal: ESP32-S3-WROOM-1-N8R8, 2.9" Waveshare e-paper, physical 4×5 keypad, 58mm TTL thermal printer, BLE, USB-C.

## Status

**Design phase — no EasyEDA schematic/PCB files exist yet.** Everything below is a written specification (GPIO map, schematic connection list, BOM, layout rules) meant to be typed into EasyEDA by following `08-EASYEDA-GUIDE.md`. Several values are marked `VERIFY AGAINST DATASHEET` — they depend on the exact physical modules (e-paper, printer, ESP32-S3 module revision) and must be confirmed before ordering a PCB.

## Read in this order

1. [`01-DESIGN-REVIEW.md`](01-DESIGN-REVIEW.md) — analysis of the original spec: what's correct, what's wrong (critical Octal-PSRAM GPIO conflict on the N8R8 module), what's missing. Read this first — it explains *why* the GPIO map and BOM look the way they do.
2. [`02-ARCHITECTURE.md`](02-ARCHITECTURE.md) — block diagram and firmware/data workflow
3. [`03-GPIO-MAP.md`](03-GPIO-MAP.md) — final, corrected GPIO assignment table (the authoritative pin reference for firmware too)
4. [`04-SCHEMATIC-CONNECTIONS.md`](04-SCHEMATIC-CONNECTIONS.md) — every net and connection, organized by schematic sheet
5. [`05-POWER-TREE.md`](05-POWER-TREE.md) — power architecture, current budget, exact decoupling capacitor values
6. [`06-BOM.md`](06-BOM.md) — full bill of materials (Rev-1 required + Rev-2 optional), with sourcing-risk notes
7. [`07-PCB-LAYOUT-ROUTING.md`](07-PCB-LAYOUT-ROUTING.md) — component placement order, trace widths, antenna keepout, RF rules
8. [`08-EASYEDA-GUIDE.md`](08-EASYEDA-GUIDE.md) — step-by-step: how to actually build this in EasyEDA (schematic → ERC → PCB → DRC → Gerbers)
9. [`09-PRODUCTION-CHECKLIST.md`](09-PRODUCTION-CHECKLIST.md) — checklist to run through before submitting Gerbers to JLCPCB/PCBWay

## Scope

**Rev-1** (this design): USB-C powered only, no battery, no RTC, no microSD, no NFC — deliberately minimal, see `01-DESIGN-REVIEW.md` §11 for why each omitted feature is deferred rather than half-built.

**Rev-2** (future, not designed yet): battery + power-path management, microSD, RTC (RV-3028), verified payment integration, possibly NFC. Do not add any Rev-2 component to the Rev-1 BOM/PCB "just in case" — see the project's overall philosophy in the top-level [`../CLAUDE.md`](../CLAUDE.md).

## What's needed from the builder before this can be finalized

- Exact connector pinout/pitch of the Waveshare 2.9" e-paper cable you own (photograph or measure it — do not assume a generic pinout)
- Exact connector type of the 58mm thermal printer module you own
- Confirmation of the exact ESP32-S3-WROOM-1-N8R8 datasheet revision (Espressif periodically revises pin tables)
- A confirmed, in-stock buck converter part number (see `06-BOM.md`, U2)

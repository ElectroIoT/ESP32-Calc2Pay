# Calc2Pay Rev-1 — EasyEDA Implementation Guide

## 1. Schematic setup

1. Create a new EasyEDA Pro (or Standard) project named `Calc2Pay-Rev1`.
2. Create 8 schematic sheets matching `04-SCHEMATIC-CONNECTIONS.md`: Power, ESP32-S3, E-Paper, Keypad, Printer, USB-C, Buttons-Buzzer-LED, Expansion. Use EasyEDA's multi-sheet project feature so nets can cross sheets via net labels (not physical wires across sheets).
3. Search EasyEDA's built-in LCSC-linked library first for every part — most passives, the ESP32-S3-WROOM-1 module, common connectors, and common buck ICs already have verified footprints and 3D models there. Only build a custom symbol/footprint when nothing suitable exists (this will likely be needed for J2 e-paper connector and J3 printer connector, since those must match your exact physical modules).
4. For any custom part (J2, J3, and possibly the keypad connector J4): measure the real connector pin pitch/count from your physical module, use EasyEDA's footprint editor to build a matching footprint, and verify against the datasheet or by physically overlaying a printed 1:1 footprint drawing before ordering.

## 2. Net labels

- Use the exact net names from `04-SCHEMATIC-CONNECTIONS.md`/spec section 27 (`+5V`, `+3V3`, `GND`, `USB_D+`, `USB_D-`, `EPD_MOSI`, etc.) consistently across every sheet — EasyEDA ties nets together globally by label text, so a typo silently creates two disconnected nets.
- Use EasyEDA's dedicated GND/power-flag symbols for `GND`, `+3V3`, `+5V`, `PRINTER_5V` rather than plain net labels, so ERC can validate them properly.

## 3. ERC (Electrical Rule Check)

- Run ERC after each sheet is wired, not just at the end — catches floating pins and net-label typos early.
- Expect and resolve: unconnected pin warnings on U1's unused strap pins (GPIO3/45/46) — mark them explicitly as "No Connect" in the symbol/ERC settings rather than leaving them silently unrouted, so ERC doesn't keep flagging them.
- Confirm every IC's power/ground pins show as connected — a common EasyEDA mistake is missing power-pin visibility on multi-part symbols.

## 4. PCB layout

1. Import the netlist into the PCB editor (2-layer board, `07-PCB-LAYOUT-ROUTING.md` for placement order).
2. Set board outline first based on measured display/keypad/printer envelope (do not finalize until those are measured, per spec section 29) — use a placeholder outline sized generously and shrink once mechanical is confirmed.
3. Place U1 first per the antenna-keepout rule, then work through the placement priority list.
4. Set design rules (Design Rule settings in EasyEDA PCB editor) before routing: minimum trace width/clearance per `07-PCB-LAYOUT-ROUTING.md`, minimum via size appropriate for a standard 2-layer JLCPCB process (0.3mm drill / 0.6mm pad is a safe standard default).
5. Route power nets first (PRINTER_5V, +3V3, GND stitching), then USB differential pair, then SPI/UART, then everything else.
6. Add copper pour (zone fill) for GND on the bottom layer, and a +3V3 or PRINTER_5V pour on the top layer only where it doesn't cross into the antenna keepout or beneath sensitive SPI/USB routing.

## 5. Copper zones

- Bottom layer: solid GND pour, connected to U1's ground pins and thermal pad via multiple vias.
- Top layer: keep mostly signal traces; a small local GND pour around U1/antenna area is fine as long as it respects the keepout boundary exactly as specified in the datasheet.
- Stitch top and bottom GND pours with vias along the board perimeter, spaced roughly every 5–10mm, and additional vias near U1 and near the buck converter's ground return.

## 6. DRC (Design Rule Check)

- Run DRC after routing is "complete" and again after any manual trace edits.
- Pay special attention to: PRINTER_5V trace width warnings (should meet or exceed the `07-PCB-LAYOUT-ROUTING.md` minimum), antenna keepout violations (EasyEDA won't automatically flag this unless you manually add a keepout region — draw one matching the datasheet dimension and set it as a routing/placement keepout), and clearance around the USB-C connector's mechanical footprint (through-hole legs need adequate annular ring/clearance).

## 7. Gerbers and fabrication output

1. Use EasyEDA's "Fabrication Output" (Gerber generation) once DRC is clean.
2. Select the standard Gerber RS-274X + Excellon drill file set (EasyEDA's default JLCPCB-compatible export is fine for PCBWay too, both accept the same format).
3. Generate and review the Gerber preview (EasyEDA's built-in viewer, or upload to JLCPCB/PCBWay's own online Gerber viewer) before submitting — visually confirm the antenna keepout area is clear, silkscreen text isn't clipped by component placement, and connector orientations look correct.
4. Export a placement/BOM file (EasyEDA can export a Pick-and-Place + BOM CSV directly) if you intend to use JLCPCB/PCBWay's SMT assembly service for the SMD parts, leaving only the connectors/switches for hand soldering.

## 8. Order checklist before submitting

- Cross-reference against `09-PRODUCTION-CHECKLIST.md` before clicking "Order."

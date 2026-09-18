# Calc2Pay Rev-1 — PCB Placement Plan & Routing Rules

## Layer count decision

**2-layer PCB is sufficient for Rev-1.** A 4-layer board would help RF/ground-plane purity and EMI margin, but at this GPIO/signal-integrity level (SPI e-paper, UART printer, no high-speed buses beyond USB2.0 full-speed, which the WROOM-1 module's certified antenna/matching already handles internally) a 2-layer board with a solid bottom ground pour and careful top-layer routing is standard practice for ESP32 dev-board-class designs and keeps manufacturing cost/lead-time down. Move to 4-layer only if prototype EMI testing shows a problem — don't pre-pay for margin you likely won't need.

## Placement priority (top layer, in order)

1. **U1 ESP32-S3-WROOM-1** — place near a PCB edge, module antenna edge flush with or overhanging the board edge, oriented so the antenna keepout zone faces open space (no components, no copper pour, no ground plane) on that edge.
2. **Antenna keepout** — maintain the module's specified keepout (typically no copper/components within the printed antenna outline plus margin on all layers, including the opposite side of the board directly behind it). **VERIFY AGAINST DATASHEET**: use the exact keepout dimension from the ESP32-S3-WROOM-1 datasheet's PCB layout reference section for the module revision you buy.
3. **J1 USB-C** — on the opposite or adjacent edge from the antenna, easily accessible for the enclosure cutout, VBUS/GND traces short and wide to F1/F2.
4. **U2 buck converter + L1 + C1/C2** — close together in a tight loop (minimize switch-node trace length), away from the antenna keepout and away from the e-paper SPI lines.
5. **J2 E-paper connector** — positioned to match the display's physical location behind the keypad in the enclosure (see `02-ARCHITECTURE.md`); keep EPD_MOSI/CLK traces short and away from the buck's switching node and away from PRINTER_5V.
6. **J4 Keypad connector** — positioned under the physical keypad area; route matrix traces on whichever layer keeps them away from the buck switch node and USB D+/D−.
7. **J3 Thermal printer connector** — positioned at the board edge facing the printer module's mounting location (top/rear of enclosure per spec section 29); keep PRINTER_5V and its return path physically separated from the e-paper SPI and USB D+/D− traces.
8. **Buzzer/LED** — placed for enclosure accessibility (buzzer needs an acoustic port, LED needs a light pipe or clear window), routed with short traces back to U1.
9. **J5 I2C, J7 debug header, GPIO48 spare pad** — placed last, along a board edge for easy probe/header access, out of the way of primary signal paths.

## Trace width / clearance rules

| Net class | Width | Clearance | Notes |
|---|---|---|---|
| PRINTER_5V and its GND return | ≥1.0mm (≈40mil) for ~2A continuous with headroom for bursts; wider (1.5mm+) preferred if board space allows | Standard 6mil/0.15mm | Use copper pour/fill for this net where possible rather than a thin trace; keep the return path directly beneath/adjacent to minimize loop area |
| +3V3 logic rail | 0.5–0.6mm (≈20-24mil) | Standard | Sufficient for ~700mA worst case over short board-scale distances |
| USB D+/D− | Differential pair, ~90Ω target impedance per 2-layer stackup calculator for your chosen dielectric, kept length-matched within a few mm, routed away from switching regulator | Keep away from PRINTER_5V and L1 switch node | Route as a tight pair, minimize layer transitions/vias |
| SPI (e-paper) | 0.2–0.25mm (≈8-10mil) | Standard | Keep MOSI/CLK reasonably short (<50mm) and away from PRINTER_5V |
| UART (printer) | 0.2–0.25mm (≈8-10mil) | Standard | Not speed-critical, but keep away from the buck's switch node to avoid noise coupling into the printer's own logic |
| I2C, buzzer, LED, GPIO signals | 0.2–0.25mm (≈8-10mil) | Standard | Non-critical |
| Ground | Solid pour, bottom layer, stitched to top-layer ground pours with vias every ~5-10mm along the board perimeter and near U1 | — | Single unbroken reference plane; do not slot it under the antenna keepout or under PRINTER_5V |

## RF-specific rules

- No copper (either layer), no components, no metal enclosure standoffs inside the WROOM-1 module's specified antenna keepout.
- Keep the printer (motor + thermal head — both can be electrically noisy) and its 5V/GND traces as far from the antenna keepout as the board outline allows.
- Do not route USB D+/D− or e-paper SPI clock lines directly beneath or immediately adjacent to the antenna keepout on either layer.

## Mounting and mechanical

- 4x mounting holes, M2 or M2.5, placed at board corners with adequate keep-out from nearby components (per standard ~3mm pad + 1.5mm annular clearance).
- Keep the antenna-facing edge of the board free of any grounded mounting hardware or metal standoffs.

## Rev-2 layout reservation (does not affect Rev-1 fabrication)

- A silkscreen-marked, unpopulated footprint area near J5/GPIO48 for a future RTC (RV-3028, SOT23-8) and/or microSD socket, sized but not connected in Rev-1's netlist.
- Optional per-key series-diode footprints (SOD-123) inline with each of the 20 keypad switch pads, left unpopulated — only add these to the PCB footprint if doing so doesn't stretch the keypad area beyond your target enclosure size; otherwise the retrofit path is a second small daughter PCB for the keypad only.

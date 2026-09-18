# Calc2Pay Rev-1 — Production Checklist

Before ordering the PCB:

- [ ] ERC passed with zero unresolved warnings (strap pins explicitly marked No Connect)
- [ ] DRC passed with zero violations, including a manually-drawn antenna keepout region
- [ ] GPIO map cross-checked line-by-line against `03-GPIO-MAP.md` and the exact ESP32-S3-WROOM-1 datasheet revision you're using
- [ ] ESP32-S3-WROOM-1-N8R8 module footprint verified against the datasheet's recommended land pattern (not just EasyEDA's library default — spot-check pad pitch)
- [ ] USB verified: D+/D− continuity to GPIO20/19, CC1/CC2 5.1kΩ pull-downs present, ESD array placed before the series resistors/MCU
- [ ] Power verified: buck converter input/output caps and inductor match its datasheet's reference design exactly, EN pin timing RC confirmed, output measured (on a bench prototype or breadboard buck module) to be a clean 3.3V under load before committing to the final BOM part
- [ ] Printer current path verified: dedicated 5V rail, separate polyfuse from logic, bulk cap at the connector, trace width meets or exceeds the 1.0mm+ recommendation
- [ ] E-paper connector verified against the physical Waveshare module/cable pinout you own (not assumed)
- [ ] Keypad verified: matrix wiring matches `03-GPIO-MAP.md`, internal pull-ups enabled in firmware plan, debounce strategy defined
- [ ] Antenna keepout verified against the datasheet dimension, no copper/components/mounting hardware inside it on either layer
- [ ] BOM verified: every "VERIFY" line item in `06-BOM.md` resolved to a real, in-stock manufacturer part number before ordering
- [ ] Footprints verified: especially J2 (e-paper) and J3 (printer), which are custom and module-specific — physically test-fit if possible before fabrication
- [ ] Gerbers checked in a Gerber viewer (EasyEDA built-in or JLCPCB/PCBWay online viewer) for correct layer stack, silkscreen legibility, and connector orientation markers
- [ ] Silkscreen reviewed: connector pin-1 markers, power/battery polarity, LED/diode polarity, IC orientation, and section labels (Calc2Pay, ESP32-S3, USB, E-PAPER, PRINTER, KEYPAD, I2C, DEBUG, BOOT, RESET) all present and not obscured by parts
- [ ] Mounting holes checked against the target enclosure's actual hole pattern (measure before finalizing, per spec section 29)

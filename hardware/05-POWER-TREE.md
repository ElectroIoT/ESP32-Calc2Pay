# Calc2Pay Rev-1 — Power Tree & Current Budget

## Power tree

```text
USB-C VBUS (5V, from host/adapter)
   │
   ├── F1 polyfuse (e.g. 1.1A hold / 2.2A trip, 0805) ──► U2 Buck 5V→3.3V ──► +3V3 rail
   │                                                                            │
   │                                                                            ├─ ESP32-S3-WROOM-1 (U1)
   │                                                                            ├─ E-paper (J2)
   │                                                                            ├─ Keypad pull-ups (J4)
   │                                                                            ├─ Status LED (via resistors)
   │                                                                            ├─ Buzzer driver pull path
   │                                                                            └─ I2C header pull-ups (J5)
   │
   └── F2 polyfuse (e.g. 2A hold / 4A trip, 1206) ──► PRINTER_5V rail ──► Thermal printer (J3)
                                                          (+ bulk cap C3 470µF, ceramic C4 100nF at connector)
```

## Regulator recommendation: buck, not LDO

**Recommendation: synchronous buck converter**, e.g. a TLV62569-class or AP63203-class 5V-in, 3.3V-out, ~1.2–2A integrated buck in SOT23-5/SOT563. **Part number needs verification** against current JLCPCB Basic/Extended stock at order time — treat "TLV62569DBVR" or "AP63203WU-7" as reference candidates, not a locked BOM line, until you confirm availability.

Why buck over LDO:
- At 5V→3.3V with a realistic 500–600mA Wi-Fi/BLE TX burst, an LDO dissipates `(5.0−3.3)×0.6A ≈ 1.02W` — too much for a small SOT23/SOT89 package in a sealed handheld enclosure with no heatsinking or airflow.
- A buck at ~85–90% efficiency dissipates a small fraction of that, and gives thermal headroom under simultaneous printer + Wi-Fi load.
- Cost delta (inductor + buck IC vs. LDO) is small at this volume and is worth the reliability margin.

## Current budget (worst case, all subsystems active simultaneously)

| Load | Typical | Peak | Rail |
|---|---|---|---|
| ESP32-S3 (Wi-Fi/BLE TX burst) | 80–150mA | ~500–600mA | 3.3V |
| E-paper (during refresh only, brief) | 5–10mA idle | ~20–30mA | 3.3V |
| Keypad, LED, buzzer driver base | <20mA combined | ~40mA (buzzer active + LED) | 3.3V |
| **3.3V rail total** | ~150mA | **~700mA** | — |
| Thermal printer (idle/standby) | 30–50mA | — | 5V |
| Thermal printer (printing, head+motor) | 0.5–1A avg | **1.5–2A burst** | 5V |
| **5V printer rail total** | ~0.7A | **~2A** | — |

Buck converter should be selected/rated for **≥1A continuous, ≥1.5A burst** on the 3.3V output with margin. Polyfuse F2 (printer) should hold at ~2A and trip above the printer's documented peak (check the exact printer module's datasheet — **VERIFY AGAINST DATASHEET**, thermal printer peak current varies significantly by print density/model).

## USB-C source requirement (user-facing note, not a hardware line item)

Standard USB 2.0 enumeration without BC1.2/PD negotiation defaults to 500–900mA @ 5V. **Printer + Wi-Fi peak (~2.6A combined) exceeds a plain laptop USB port's budget.** Rev-1 should ship with (or explicitly instruct the user to use) a **5V/2A–3A rated USB-C power adapter/charger**, not a data-only PC port, for reliable printing under load. This is a usage requirement, not a schematic change — document it in the product manual.

## Decoupling table (spec section 22 — exact values, not "add capacitors")

| Component | Value | Voltage | Package | Location | Purpose |
|---|---|---|---|---|---|
| C1 | 10µF | 16V, X7R | 0805 | U2 buck VIN pin | Input bulk decoupling |
| C2 | 22µF | 10V, X7R | 1206 | U2 buck VOUT pin | Output ripple filtering |
| L1 | 2.2µH (per chosen buck IC datasheet) | Isat ≥ 1.5A | Shielded SMD inductor | U2 switch node | Buck energy storage |
| C3 | 470µF | 16V | Electrolytic, radial SMD (e.g. 6.3x7.7mm) | At J3 printer connector | Absorbs printer head/motor current transients |
| C4 | 100nF | 25V, X7R | 0603 | At J3, next to C3 | High-frequency printer noise bypass |
| C5 | 100nF | 16V, X7R | 0402/0603 | Directly at U1 3V3 pin | ESP32-S3 local HF decoupling |
| C6 | 10µF | 10V, X7R | 0805 | Directly at U1 3V3 pin | ESP32-S3 local bulk decoupling |
| C7 | 100nF | 16V, X7R | 0603 | At J2 e-paper VCC pin | E-paper module decoupling |
| C8 (EN cap) | 1µF | 16V, X7R | 0603 | U1 EN pin to GND | Power-on reset timing per Espressif ref design |
| C9 (GPIO0 debounce, optional) | 100nF | 16V, X7R | 0603 | U1 GPIO0 to GND | Boot-pin noise immunity |

## Battery (Rev-2 note, not implemented in Rev-1)

Do not add a TP4056-only charger for the final product per spec section 16 — a real POS device needs a proper charge/power-path IC (e.g. a linear charger with power-path management, or a dedicated charger+PMIC) so the device can run from USB while charging and hand off to battery cleanly, plus a 5V boost stage sized for printer peak current feeding off the battery when unplugged. This is architecturally a bigger change than a Rev-1 footprint can absorb correctly, so **Rev-1 ships with no battery connector at all** rather than an unpopulated footprint that implies a topology that doesn't exist yet. Design this properly as its own power-tree revision in Rev-2.

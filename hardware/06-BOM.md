# Calc2Pay Rev-1 — Bill of Materials

Part numbers marked **VERIFY** are reference candidates only — confirm exact manufacturer part number and current stock (JLCPCB/PCBWay/LCSC) before ordering. None are invented as "confirmed" without that caveat.

## Required — Rev-1

| Ref | Part | Manufacturer | MPN | Value | Package | Qty | Purpose | Sourcing risk |
|---|---|---|---|---|---|---|---|---|
| U1 | ESP32-S3-WROOM-1-N8R8 | Espressif | ESP32-S3-WROOM-1-N8R8 | — | SMD module, 18x25.5mm | 1 | Main MCU | Low — widely stocked |
| U2 | Buck converter 5V→3.3V | TI or Anpec | **VERIFY** (e.g. TLV62569DBVR / AP63203WU-7) | 3.3V out, ≥1.2A | SOT23-5/SOT563 | 1 | 3.3V logic rail | Medium — confirm exact stock at order time |
| L1 | Shielded power inductor | Murata/TDK | **VERIFY** (per U2 datasheet) | 2.2µH, Isat≥1.5A | SMD 2.5x2.5mm class | 1 | Buck inductor | Low |
| U3 | USB ESD protection array | Onsemi/ST | **VERIFY** (e.g. USBLC6-2SC6) | — | SOT-23-6 | 1 | USB D+/D- ESD protection | Low |
| J1 | USB-C receptacle, 16-pin | GCT/Amphenol | **VERIFY** | — | SMD, through-hole legs | 1 | Power + programming | Low |
| J2 | E-paper connector | Match Waveshare cable | **VERIFY against your exact module's connector (FPC/pin header)** | — | — | 1 | E-paper interface | Depends on module revision you own |
| J3 | Printer connector | Match printer module cable | **VERIFY against your exact printer's connector type** | — | — | 1 | Thermal printer interface | Depends on printer model |
| J4 | Keypad header/FPC | Generic | **VERIFY** | — | — | 1 | Matrix keypad interface | Low |
| J5 | I2C header, 4-pin | Generic | 2.54mm pin header | — | THT | 1 | Future expansion | Low |
| J7 | Debug header, 6-pin | Generic | 2.54mm pin header | — | THT | 1 | UART/EN/IO0 debug | Low |
| F1 | Polyfuse | Bel/Littelfuse | **VERIFY** (~1.1A hold) | 1.1A/16V | 0805 | 1 | Logic rail protection | Low |
| F2 | Polyfuse | Bel/Littelfuse | **VERIFY** (~2A hold) | 2A/16V | 1206 | 1 | Printer rail protection | Low |
| C1 | Ceramic cap | Generic | — | 10µF/16V X7R | 0805 | 1 | Buck input decoupling | Low |
| C2 | Ceramic cap | Generic | — | 22µF/10V X7R | 1206 | 1 | Buck output decoupling | Low |
| C3 | Electrolytic cap | Generic | — | 470µF/16V | Radial SMD | 1 | Printer surge absorption | Low |
| C4 | Ceramic cap | Generic | — | 100nF/25V X7R | 0603 | 1 | Printer HF bypass | Low |
| C5 | Ceramic cap | Generic | — | 100nF/16V X7R | 0402/0603 | 1 | ESP32-S3 3V3 decoupling | Low |
| C6 | Ceramic cap | Generic | — | 10µF/10V X7R | 0805 | 1 | ESP32-S3 3V3 bulk decoupling | Low |
| C7 | Ceramic cap | Generic | — | 100nF/16V X7R | 0603 | 1 | E-paper decoupling | Low |
| C8 | Ceramic cap | Generic | — | 1µF/16V X7R | 0603 | 1 | EN pin RC timing | Low |
| C9 | Ceramic cap | Generic | — | 100nF/16V X7R | 0603 | 1 | GPIO0 debounce (optional) | Low |
| R1 | Resistor | Generic | — | 10kΩ | 0603 | 1 | EN pull-up | Low |
| R2 | Resistor | Generic | — | 5.1kΩ | 0603 | 2 | USB-C CC1/CC2 | Low |
| R3 | Resistor | Generic | — | 22Ω (optional) | 0603 | 2 | USB D+/D- series | Low |
| R4 | Resistor | Generic | — | 4.7kΩ | 0603 | 2 | I2C SDA/SCL pull-ups | Low |
| R5 | Resistor | Generic | — | 330Ω | 0603 | 1 | LED Red current limit | Low |
| R6 | Resistor | Generic | — | 220Ω | 0603 | 2 | LED Green/Blue current limit | Low |
| R7 | Resistor | Generic | — | 1kΩ | 0603 | 1 | Buzzer transistor base | Low |
| Q1 | NPN transistor | Onsemi | MMBT2222A | — | SOT-23 | 1 | Buzzer driver | Low |
| D1 | Signal diode | Onsemi | 1N4148W | — | SOD-123 | 1 | Buzzer flyback protection | Low |
| LED1 | RGB LED, common cathode | Generic | **VERIFY** | — | 0805/PLCC-4 | 1 | Status indicator | Low |
| BZ1 | Active piezo buzzer | Generic | **VERIFY** | 3.3V/5V rated | SMD or THT | 1 | Audible feedback | Low |
| SW1 | Tactile button | Generic | — | — | SMD 3x3mm | 1 | BOOT | Low |
| SW2 | Tactile button | Generic | — | — | SMD 3x3mm | 1 | RESET | Low |
| SW3 | Tactile button | Generic | — | — | SMD 3x3mm | 1 | User button | Low |
| SW4-23 | Keypad switches (20x) | Generic | **VERIFY (mechanical/membrane per keypad design)** | — | — | 20 | Physical keypad | Low |
| — | 2.9" e-paper module | Waveshare | Per your existing unit | 296x128 | Module | 1 | Display (external, cabled) | You already own it |
| — | 58mm TTL thermal printer | Generic | Per your existing unit | — | Module | 1 | Receipt printing (external, cabled) | You already own it |
| — | Mounting hardware | Generic | M2/M2.5 standoffs+screws | — | — | 4 | Enclosure mounting | Low |

## Optional / Future (Rev-2)

| Ref | Part | Purpose |
|---|---|---|
| U4 | RV-3028 RTC | Timestamped transactions |
| — | microSD socket | Local transaction/config storage |
| — | Li-ion charger/PMIC + boost | Battery operation |
| J6 | Battery connector | Rev-2 only, not populated in Rev-1 |
| — | Series diodes (20x, SOD-123, e.g. 1N4148W) | Keypad ghosting elimination if needed |
| — | NFC module | Future contactless feature |

## Sourcing notes

- Easy to source at any volume: passives (R/C), transistor Q1, diode D1, tactile buttons, USB-C connector, polyfuses.
- Needs alternates on hand: buck converter U2 and ESD array U3 — pick a second-source part number before ordering in case of stock-outs (common on small analog ICs).
- Supply-risk items: exact e-paper cable connector (J2) and printer connector (J3) footprints depend entirely on the specific modules you already own — measure/photograph the connectors before finalizing footprints, do not guess pin pitch.

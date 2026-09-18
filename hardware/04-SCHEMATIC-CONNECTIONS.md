# Calc2Pay Rev-1 — Complete Schematic Connection List

Organized as 8 EasyEDA sheets per spec section 26. Net names per spec section 27.

## Sheet 1 — Power

- J1 USB-C VBUS → F1 (polyfuse, logic) → U2 buck converter VIN
- J1 USB-C VBUS → F2 (polyfuse, printer) → PRINTER_5V net → J3 pin (printer VCC)
- U2 buck converter (5V→3.3V) OUT → +3V3 net (star point)
- U2 EN tied to VIN (or internal default enable) per chosen part's datasheet
- Input cap C1 (10µF/16V, X7R, 0805) across VIN/GND at U2
- Output cap C2 (22µF/10V, X7R, 1206) across +3V3/GND at U2
- Inductor L1 per U2 datasheet (e.g. 2.2µH, shielded, 0.6A-1A saturation minimum — VERIFY AGAINST CHOSEN BUCK IC DATASHEET)
- Bulk electrolytic C3 (470µF/16V) directly across PRINTER_5V/GND at J3, placed as close to printer connector as possible
- Ceramic C4 (100nF/25V, 0603) across PRINTER_5V/GND, close to C3
- +3V3 net feeds: U1 (ESP32-S3), J2 (e-paper), J4 (keypad — pull-ups only, matrix itself is dry-contact), buzzer driver pull-up if needed, status LED anodes (if common-anode) or via resistors, J5 I2C pull-ups
- GND is a single unbroken plane on the bottom copper layer (2-layer board); star-point tie between PRINTER_5V return and logic GND return at a single point near F1/F2 to avoid printer switching noise injecting into logic ground

## Sheet 2 — ESP32-S3-WROOM-1-N8R8 (U1)

- U1 pin 3V3 → +3V3 net, with C5 (100nF, 0402/0603) and C6 (10µF, 0805) local decoupling directly at the pin
- U1 EN pin → RC network: 10kΩ pull-up to +3V3, 1µF cap to GND (Espressif reference reset timing), plus RESET button to GND in parallel
- U1 GPIO0 → BOOT button to GND, 10kΩ internal pull-up relied on (add external 10kΩ to +3V3 only if the exact module revision recommends it — VERIFY AGAINST DATASHEET), 100nF cap GPIO0-to-GND for debounce/noise per common ESP32 practice
- U1 GPIO19/20 → USB_D−/USB_D+ nets (Sheet 6)
- U1 GPIO45, GPIO46 → no connection to any external circuit (leave per internal strap default; do not float over long unshielded traces — keep short and away from noise)
- U1 GPIO3 → no connection (reserved for future JTAG, silkscreen-labeled test pad only)
- All other U1 GPIOs → route to nets defined in `03-GPIO-MAP.md`
- U1 ground pins + exposed thermal pad → solid GND plane with multiple vias (thermal relief per Espressif ref layout)

## Sheet 3 — E-Paper (J2, connector matching the exact Waveshare 2.9" cable/header — confirm pinout against the module you own before finalizing footprint)

- J2.VCC → +3V3
- J2.GND → GND
- J2.DIN (MOSI) → EPD_MOSI (GPIO11)
- J2.CLK → EPD_CLK (GPIO12)
- J2.CS → EPD_CS (GPIO13)
- J2.DC → EPD_DC (GPIO14)
- J2.RST → EPD_RST (GPIO15)
- J2.BUSY → EPD_BUSY (GPIO16)
- Local decoupling: C7 (100nF, 0603) at J2.VCC/GND, placed within 5mm of the connector

## Sheet 4 — Keypad (J4, 9-pin header or FPC to matrix PCB/membrane)

- J4.R1–R4 → GPIO1, 2, 4, 5 (KEY_R1–R4)
- J4.C1–C5 → GPIO6, 7, 8, 9, 10 (KEY_C1–C5)
- No external pull-ups (internal pull-ups on column inputs, firmware-enabled)
- Optional Rev-2 footprint: series diode (SOD-123, e.g. 1N4148W) pad in line with each of the 20 key switch positions, unpopulated in Rev-1 (see `01-DESIGN-REVIEW.md` §6)

## Sheet 5 — Thermal Printer (J3, matches the exact 58mm TTL printer module's connector — VERIFY AGAINST DATASHEET for pinout/connector type)

- J3.VCC → PRINTER_5V (not +3V3 — dedicated rail, Sheet 1)
- J3.GND → GND (shared plane, single star point back to Sheet 1)
- J3.TX → PRINTER_RX net → U1 GPIO18
- J3.RX → PRINTER_TX net → U1 GPIO17
- Bulk cap C3 and ceramic C4 physically at this connector (see Sheet 1), not just at the regulator

## Sheet 6 — USB-C (J1)

- J1.VBUS → Sheet 1 power input (through F1/F2 as shown)
- J1.GND → GND
- J1.CC1 → 5.1kΩ resistor to GND (device-mode identification, USB 2.0/BC1.2 compatible, no PD)
- J1.CC2 → 5.1kΩ resistor to GND
- J1.D+ → optional 22Ω series resistor → U3 ESD protection array → U1 GPIO20
- J1.D− → optional 22Ω series resistor → U3 ESD protection array → U1 GPIO19
- U3 (USB ESD protection diode array, e.g. USBLC6-2SC6-class part) grounded per its datasheet, placed directly at the connector before the series resistors/MCU
- Shield/shell of J1 → GND (chassis/earth reference, keep shield connection short)

## Sheet 7 — Buttons / Buzzer / LED

- SW1 BOOT → GPIO0 to GND (Sheet 2)
- SW2 RESET → EN to GND (Sheet 2)
- SW3 USER_BUTTON → GPIO41 to GND, internal pull-up enabled in firmware
- Buzzer driver: GPIO21 → R (1kΩ, 0603) → Q1 base (NPN, e.g. MMBT2222A or S8050 SOT-23) → buzzer negative lead; buzzer positive lead → +3V3 (or PRINTER_5V-derived if a louder 5V buzzer is chosen — VERIFY buzzer voltage rating before wiring); Q1 collector → buzzer negative; Q1 emitter → GND; flyback diode D1 (1N4148) across buzzer terminals, cathode to +3V3/5V side, in case a magnetic (inductive) buzzer is used instead of piezo
- Status RGB LED: common-cathode RGB LED, cathode → GND; GPIO38 → R1 (330Ω) → LED Red anode; GPIO39 → R2 (220Ω) → LED Green anode; GPIO40 → R3 (220Ω) → LED Blue anode (resistor values assume a typical 3.3V logic-level RGB LED — VERIFY Vf of the exact LED chosen and recompute per `05-POWER-TREE.md`)

## Sheet 8 — Expansion

- J5 I2C header: pin1 +3V3, pin2 GND, pin3 SDA (GPIO42), pin4 SCL (GPIO47); R (4.7kΩ) pull-ups on SDA/SCL to +3V3, placed near J5
- J7 Debug header: 3V3, GND, TX (GPIO43/U0TXD), RX (GPIO44/U0RXD), EN, IO0(GPIO0) — all silkscreen-labeled; optional 2 extra pads for USB_D+/D− test points (not a connector, just probe pads)
- GPIO48: silkscreen-labeled test pad only, no connector, reserved for Rev-2 (microSD CS or RTC INT candidate)
- J6 optional battery header: 2-pin, unpopulated footprint only, **not wired into the power tree in Rev-1** (see `05-POWER-TREE.md` §Battery) — placement reserved but no traces committed to a charge path yet, to avoid designing a broken charger topology now

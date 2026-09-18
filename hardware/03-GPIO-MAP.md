# Calc2Pay Rev-1 — Final GPIO Map

Base module: **ESP32-S3-WROOM-1-N8R8** (8MB Quad Flash + 8MB Octal PSRAM).
**VERIFY AGAINST DATASHEET**: cross-check every row below against the Espressif ESP32-S3-WROOM-1 datasheet revision current at order time, and against the ESP32-S3 Series Datasheet's strapping-pin table.

Permanently reserved by the module (never route to any connector or peripheral):

| GPIO | Reserved for |
|---|---|
| 26–32 | SPI Flash (all WROOM-1 variants) |
| 33–37 | Octal PSRAM (N8R8/R16 variants only) |
| 19, 20 | Native USB D−/D+ |
| 0 | Boot-mode strap (BOOT button only) |
| 45 | VDD_SPI voltage-select strap — leave unconnected |
| 46 | Boot-mode strap, input-only — unused in Rev-1 |
| 3 | JTAG-source strap — left unconnected, no pull networks, reserved for future JTAG debug |

## Final assignment table

| GPIO | Function | Peripheral | Direction | Pull-up/down | Notes |
|---|---|---|---|---|---|
| 0 | BOOT | Boot strap | Input | Internal pull-up (chip default) | Momentary button to GND, 100nF debounce cap, per Espressif ref design |
| 1 | KEY_R1 | Keypad row 1 | Output | None (driven) | Active-low row scan |
| 2 | KEY_R2 | Keypad row 2 | Output | None (driven) | Active-low row scan |
| 4 | KEY_R3 | Keypad row 3 | Output | None (driven) | Active-low row scan |
| 5 | KEY_R4 | Keypad row 4 | Output | None (driven) | Active-low row scan |
| 6 | KEY_C1 | Keypad col 1 | Input | Internal pull-up (firmware) | No external pull-up needed |
| 7 | KEY_C2 | Keypad col 2 | Input | Internal pull-up (firmware) | |
| 8 | KEY_C3 | Keypad col 3 | Input | Internal pull-up (firmware) | |
| 9 | KEY_C4 | Keypad col 4 | Input | Internal pull-up (firmware) | |
| 10 | KEY_C5 | Keypad col 5 | Input | Internal pull-up (firmware) | |
| 11 | EPD_MOSI | E-paper SPI | Output | None | SPI bus, shared only with e-paper in Rev-1 |
| 12 | EPD_CLK | E-paper SPI | Output | None | |
| 13 | EPD_CS | E-paper CS | Output | External or internal pull-up idle-high | Active-low chip select |
| 14 | EPD_DC | E-paper D/C | Output | None | Data/command select |
| 15 | EPD_RST | E-paper reset | Output | None | Active-low reset |
| 16 | EPD_BUSY | E-paper busy | Input | None (module drives it) | Poll or interrupt |
| 17 | PRINTER_TX | Thermal printer UART | Output (UART TX) | None | ESP32 TX → Printer RX |
| 18 | PRINTER_RX | Thermal printer UART | Input (UART RX) | None | ESP32 RX ← Printer TX |
| 21 | BUZZER | Buzzer driver | Output | None | Drives transistor base via resistor, not the buzzer directly |
| 38 | STATUS_LED_R | RGB status LED | Output | None | Through current-limit resistor |
| 39 | STATUS_LED_G | RGB status LED | Output | None | Through current-limit resistor |
| 40 | STATUS_LED_B | RGB status LED | Output | None | Through current-limit resistor |
| 41 | USER_BUTTON | Spare user button | Input | Internal pull-up | General purpose / future long-press function |
| 42 | I2C_SDA | Expansion I2C | Bidirectional (open-drain) | External 4.7kΩ pull-up to 3V3 | Header only, unpopulated devices in Rev-1 |
| 43 | DEBUG_TX (U0TXD) | Debug UART0 | Output | None | Default IDF console UART; also debug header pin |
| 44 | DEBUG_RX (U0RXD) | Debug UART0 | Input | None | Default IDF console UART; also debug header pin |
| 47 | I2C_SCL | Expansion I2C | Output (open-drain) | External 4.7kΩ pull-up to 3V3 | Header only |
| 48 | SPARE | Reserved, Rev-2 | — | — | Not populated to any connector in Rev-1; silkscreen test pad only |
| 19 | USB_D− | Native USB | Bidirectional | None (USB PHY internal) | To J1 USB-C |
| 20 | USB_D+ | Native USB | Bidirectional | None (USB PHY internal) | To J1 USB-C |

**Total general-purpose GPIO used: 22 of ~25 available** (excluding strapping/USB/Flash/PSRAM-reserved pins). One spare (GPIO48) kept free.

## Firmware-side confirmation checklist (spec section 28, firmware column)

- [x] Keypad scanning: 4 outputs + 5 inputs, none overlapping strap/USB/reserved pins.
- [x] E-paper: full 6-signal SPI + control set on contiguous, non-reserved pins.
- [x] Printer: standard UART pair, not sharing pins with anything else.
- [x] BLE/Wi-Fi: no GPIO needed beyond antenna (internal to module) — confirmed no conflict.
- [x] USB: fixed to GPIO19/20 as required by silicon, not reassignable.
- [x] Buzzer: single GPIO through driver transistor, not direct drive.
- [x] Status LED: 3 GPIO, all outside reserved ranges.

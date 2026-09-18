// Calc2Pay firmware — GPIO pin map.
// SOURCE OF TRUTH: ../../hardware/03-GPIO-MAP.md — do not edit pin numbers here
// without updating that file first (and checking it against the Flash/Octal-PSRAM/
// strapping-pin reserved ranges documented in ../../hardware/01-DESIGN-REVIEW.md).
#pragma once

// Keypad matrix (4 rows x 5 columns)
#define PIN_KEY_R1      1
#define PIN_KEY_R2      2
#define PIN_KEY_R3      4
#define PIN_KEY_R4      5
#define PIN_KEY_C1      6
#define PIN_KEY_C2      7
#define PIN_KEY_C3      8
#define PIN_KEY_C4      9
#define PIN_KEY_C5      10

// E-paper (SPI)
#define PIN_EPD_MOSI    11
#define PIN_EPD_CLK     12
#define PIN_EPD_CS      13
#define PIN_EPD_DC      14
#define PIN_EPD_RST     15
#define PIN_EPD_BUSY    16

// Thermal printer (UART)
#define PIN_PRINTER_TX  17  // ESP32 TX -> Printer RX
#define PIN_PRINTER_RX  18  // ESP32 RX <- Printer TX

// Buzzer (through NPN transistor driver, see hardware/04-SCHEMATIC-CONNECTIONS.md Sheet 7)
#define PIN_BUZZER      21

// Status RGB LED (common cathode, through current-limit resistors)
#define PIN_LED_R       38
#define PIN_LED_G       39
#define PIN_LED_B       40

// Spare user button
#define PIN_USER_BUTTON 41

// Expansion I2C
#define PIN_I2C_SDA     42
#define PIN_I2C_SCL     47

// Debug UART0 (also the default IDF/Arduino console — GPIO43/44)
#define PIN_DEBUG_TX    43
#define PIN_DEBUG_RX    44

// GPIO 0 (BOOT strap), 3 (JTAG strap), 19/20 (native USB), 45/46 (straps) and
// 26-37 (Flash + Octal PSRAM) are RESERVED — never assign them here.
// GPIO 48 is the one spare pin, intentionally left unassigned in Rev-1.

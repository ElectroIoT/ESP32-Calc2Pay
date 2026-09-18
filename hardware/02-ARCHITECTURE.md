# Calc2Pay Rev-1 — Final Architecture

## A. Block diagram

```text
                         ┌──────────────────────────────┐
                         │        USB-C Connector (J1)   │
                         │   VBUS  GND  D+  D-  CC1 CC2  │
                         └───────┬───────────┬────────────┘
                                 │           │
                     VBUS(5V) ───┤           └── D+/D- ──► ESP32-S3 native USB (GPIO20/19)
                                 │
                 ┌───────────────┴────────────────┐
                 │                                 │
          Polyfuse (printer)                Polyfuse (logic)
                 │                                 │
                 ▼                                 ▼
        PRINTER_5V rail                     Buck converter 5V→3.3V
        (bulk cap bank)                             │
                 │                                  ▼
                 ▼                             +3V3 rail
      Thermal Printer (J3, UART)      ┌───────────────┼────────────────┐
                                       ▼               ▼                ▼
                              ESP32-S3-WROOM-1   E-Paper (J2)     Keypad (J4)
                              -N8R8 (BLE/WiFi)   2.9" 296x128       4x5 matrix
                                       │               SPI
                     ┌─────────────────┼─────────────────┬───────────────┐
                     ▼                 ▼                 ▼               ▼
               Buzzer driver     Status RGB LED     I2C header (J5)  Debug UART (J7)
               (transistor)      (3x GPIO+R)        (SDA/SCL, 3V3)   (U0TXD/RXD, EN, IO0)
```

## B. Firmware/data workflow (unchanged from spec, confirmed feasible with this hardware)

```text
Physical keypad (9 GPIO matrix scan, debounced)
      ↓
ESP32-S3 calculator engine (expression parser, GST/discount math)
      ↓
Amount shown on e-paper (partial refresh region)
      ↓
QR key pressed → build UPI URI payload (upi://pay?pa=...&am=...)
      ↓
QR encoder (firmware library) → 1-bit bitmap
      ↓
SPI → E-paper full/partial refresh → "SCAN TO PAY" screen
      ↓
Customer scans with any UPI app (Rev-1: no payment confirmation feedback loop)
      ↓
PRINT key pressed → build ESC/POS-style receipt text
      ↓
UART → thermal printer → paper receipt
      ↓
BLE (Android app): merchant config push/pull, future transaction log sync
```

## C. Design priorities (in order, per spec section 34)

1. Simplicity — no controller ICs beyond MCU + regulator + LED/buzzer drivers.
2. Reliability — dedicated printer power path, correct strap-pin handling, buck instead of hot LDO.
3. Manufacturability — 2-layer PCB, common 0805/SOT packages, JLCPCB-standard parts wherever possible.
4. Expandability — I2C header, debug header, spare GPIO (GPIO48), battery footprint feasibility documented for Rev-2, without adding any Rev-2 components to Rev-1's BOM or layout complexity.

# Calc2Pay Rev-1 — Design Review (Read This First)

Per the spec's rule 33, this review comes before the final design. Corrections below feed directly into `03-GPIO-MAP.md`, `05-POWER-TREE.md`, and `06-BOM.md`.

## 1. What is correct in the original brief

- ESP32-S3-WROOM-1-N8R8 as MCU: right call — native USB, BLE, enough Flash/PSRAM for QR bitmap + e-paper framebuffer + calculator/BLE stack.
- No keypad controller IC, no USB-UART IC, no separate BLE IC — all justified. Direct GPIO matrix scan is fine at 20 keys.
- E-paper only for calculator/QR/status, not a virtual keypad — correct UX call, saves GPIO and refresh time.
- Rev-1 = USB-C powered only, no battery, no RTC, no microSD, no NFC — right scope for a buildable v1.
- Native USB on ESP32-S3 for programming, no USB-UART bridge — correct, S3 supports USB CDC/JTAG natively.
- Separate 5V path for the printer, not sharing the 3.3V rail — correct and necessary.

## 2. Critical GPIO problem: N8R8 uses Octal PSRAM pins

**This is the single biggest error in the provisional map.** The "N8R8" suffix means 8MB Flash (quad SPI) **+ 8MB Octal PSRAM**. On ESP32-S3-WROOM-1 modules with Octal PSRAM, the following pins are bonded out internally to the PSRAM/Flash and are **not available on the module's external pins at all**:

| GPIO | Internal function | Available to user? |
|---|---|---|
| 26–32 | SPI0/SPI1 Flash (CS, CLK, D0–D3, HD, WP) | **No — reserved on every WROOM-1 variant** |
| 33 | SPIIO4 (Octal PSRAM) | **No — reserved on R8/R16 (octal PSRAM) variants only** |
| 34 | SPIIO5 (Octal PSRAM) | **No** |
| 35 | SPIIO6 (Octal PSRAM) | **No** |
| 36 | SPIIO7 (Octal PSRAM) | **No** |
| 37 | SPIDQS (Octal PSRAM) | **No** |

The provisional map assigned **GPIO 35, 36, 37** to USER BUTTON, STATUS LED, and FUTURE. **These pins do not exist externally on an N8R8 module** — they are consumed by PSRAM. This must be corrected; see `03-GPIO-MAP.md`.

**VERIFY AGAINST DATASHEET**: confirm this against the exact ESP32-S3-WROOM-1 datasheet revision you order (Espressif has revised the module pinout table across hardware revisions; the 26–37 reservation for N8R8 has been stable for years but always re-check the datasheet dated at your order time).

## 3. Strapping pins — handle with care, don't remove from use blindly

| GPIO | Role | Rev-1 treatment |
|---|---|---|
| 0 | Boot mode select, internal weak pull-up | BOOT button to GND, per Espressif reference (already planned) |
| 3 | JTAG source strap at reset, no internal pull | Leave unused by any circuit with external pull resistors; safe to use as a plain digital input with no pull network (used here for nothing in Rev-1 — kept free for debug/JTAG) |
| 45 | VDD_SPI voltage select strap, internal weak pull-down | Do **not** connect to any pull-up or driven signal — leave per module's own internal strap, do not route to a connector |
| 46 | Boot-mode strap, **input-only pin**, internal weak pull-down | Usable later only as an input with no pull-up fighting it; not used in Rev-1 |

None of GPIO 0/3/45/46 are used for general peripherals in the corrected map — this avoids boot-mode surprises entirely.

## 4. USB pins

GPIO19 (D−) and GPIO20 (D+) are correct — these are the only pins wired to the native USB PHY on ESP32-S3 and cannot be reassigned. Kept as-is.

## 5. Corrected/unavailable GPIO summary

| Original proposal | Problem | Replacement | Reason |
|---|---|---|---|
| GPIO35 → USER BUTTON | Reserved for Octal PSRAM (SPIIO6) | GPIO41 | Free general-purpose pin, no strap/PSRAM/flash function |
| GPIO36 → STATUS LED | Reserved for Octal PSRAM (SPIIO7) | GPIO38/39/40 (RGB, 3 pins) | Free pins; RGB LED needs 3 GPIOs anyway |
| GPIO37 → FUTURE | Reserved for Octal PSRAM (SPIDQS) | GPIO48 | Free pin, reserved for Rev-2 expansion |
| GPIO38 → FUTURE SPI CS | Fine electrically, but original plan under-allocated e-paper/keypad first | Reassigned into core e-paper/keypad bus (see GPIO map) | Keeps a contiguous, easy-to-route pin block for the SPI display instead of scattering it after 32 |
| GPIO39–41 → FUTURE SPI MOSI/CLK/MISO | Same as above | Folded into I2C + status LED + user button | Rev-1 has no SPI expansion device to justify reserving 3 pins; I2C header is enough per spec section 13 |
| GPIO42/43 → FUTURE I2C | Workable, but GPIO43 is also the default U0TXD (UART0 console pin) | Keep GPIO43/44 as the **debug UART** (matches spec's own debug-header ask in section 20); move I2C to GPIO42 (SDA) + GPIO47 (SCL) | Using the chip's default UART0 pins for the debug header is the standard, lowest-risk choice, and frees a clean pair for I2C |

No other proposed GPIO conflicts with Flash/PSRAM/strapping/USB once the above is applied.

## 6. Keypad: ghosting and diodes

With a 4×5 matrix scanned by firmware, **ghosting/masking is possible whenever 3+ keys are held simultaneously** in certain rectangular patterns — the classic n-key rollover problem. For a calculator, single-key-at-a-time entry is the overwhelmingly common use pattern, and firmware-side "ignore obviously-impossible combinations" handles the rare accidental double-press adequately.

**Recommendation for Rev-1: no diodes.** Reasons:
- Adds 20 diodes (BOM/assembly cost) for a failure mode (3-key ghost) that's cosmetic on a calculator, not safety-critical.
- Firmware debounce + "scan one row active-low at a time, others high-Z" already prevents most false triggers.
- If real-world testing shows ghost keypresses are annoying, Rev-2 can add a 1N4148W (SOD-123) diode in series with each key — pads can optionally be reserved in the PCB footprint now (a series diode footprint next to each switch) without populating them, at near-zero layout cost. This is called out as a Rev-2 footprint option in `07-PCB-LAYOUT-ROUTING.md`.

Rows are firmware-driven outputs (open-drain or push-pull, actively scanned), columns are inputs with **internal pull-ups enabled in firmware** — no external pull-up resistors needed (ESP32-S3 GPIOs have configurable internal pull-ups adequate for a short PCB-trace keypad matrix).

## 7. Power problems in the original brief

1. **LDO vs buck**: A 5V→3.3V linear regulator dissipates `(5V−3.3V) × I`. At a realistic ESP32-S3 Wi-Fi/BLE TX peak of ~500–600 mA, that's ~1W in a small SOT23/SOT89 package — thermally marginal in a handheld enclosure with no airflow, and it wastes ~34% of input power as heat. **Recommendation: synchronous buck converter**, not LDO. See `05-POWER-TREE.md` for the exact part and current budget.
2. **Printer and 3.3V rail must not share a regulator or a return path bottleneck** — the brief already asked for this; confirmed correct, and formalized with separate polyfuses per rail in the BOM.
3. **USB-C VBUS current budget**: printer motor + head can spike to 1.5–2A momentarily (thermal printers are bursty). A standard USB-C source (5V/500mA–900mA per USB-IF default, or up to 3A if CC resistors advertise it) must be sized correctly — the CC pull-down value doesn't request higher current by itself, so Rev-1 should assume the enumeration default (900 mA @ 5V for USB 2.0 unless a PD/BC1.2 wall adapter is used) unless a "5V/2.4A dedicated charger" USB-C cable/adapter is explicitly required. **This is called out in section 7 of `05-POWER-TREE.md` as a user-facing requirement: use a 5V/2A-3A rated USB-C power adapter, not a data-only laptop USB port**, because a laptop USB-A/C port cannot supply printer + Wi-Fi peak current simultaneously.

## 8. RF/USB problems

- Original brief already asks for correct antenna keepout and module-near-edge placement — retained as-is in `07-PCB-LAYOUT-ROUTING.md`.
- USB D+/D− need an ESD protection diode array (e.g., USBLC6-2SC6-class device) between the connector and GPIO19/20 — this was implied but not itemized; added to BOM.
- No USB-UART bridge needed; native USB confirmed correct.

## 9. Thermal-printer power problems

- Confirmed: printer must run off a dedicated 5V path with its own bulk capacitance, not off the 3.3V logic rail or through the buck converter's output.
- Added: a polyfuse (resettable fuse) sized above worst-case printer surge but below the USB-C source's current limit, plus a bulk electrolytic (see `05-POWER-TREE.md` for exact values) directly at the printer connector to absorb head/motor current transients without sagging VBUS enough to brown out the ESP32-S3's own 3.3V rail.

## 10. Mechanical problems

- None fatal at this stage; exact dimensions are correctly deferred until the actual Waveshare 2.9" module, keypad, and printer are measured (per section 29). `07-PCB-LAYOUT-ROUTING.md` gives placement zones, not final millimeter dimensions.

## 11. Components judged unnecessary for Rev-1 (confirmed against spec's own "don't overengineer" rule)

- Keypad controller IC — not needed, direct GPIO scan works.
- Separate BLE IC — not needed, ESP32-S3 has BLE 5.
- USB-UART bridge IC — not needed, native USB.
- RTC — deferred to Rev-2 (RV-3028 footprint reserved via I2C header only).
- microSD — deferred to Rev-2 (not even a footprint in Rev-1, to avoid SPI/RF layout complexity next to the antenna keepout).
- NFC — deferred to Rev-2, not scoped.
- Battery charger — deferred to Rev-2; Rev-1 gets an unpopulated 2-pin battery header footprint only if it doesn't affect the power topology (see `05-POWER-TREE.md`), otherwise omitted entirely.

## 12. Components missing from the original brief, now added

- USB ESD protection diode (USB D+/D−).
- Polyfuse on USB-C VBUS input, and a second polyfuse dedicated to the printer 5V rail.
- Reverse-polarity/back-feed protection diode consideration on the printer 5V path if the printer module can be hot-plugged.
- Bulk capacitor bank at the printer connector (not just at the regulator).
- Series resistors (~22 Ω, optional per Espressif ref design) on USB D+/D− for signal integrity.
- Explicit BOOT/RESET button debounce capacitors per Espressif's reference schematic.

All of the above are itemized in `06-BOM.md` and wired in `04-SCHEMATIC-CONNECTIONS.md`.

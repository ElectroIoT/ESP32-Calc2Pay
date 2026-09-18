// E-paper UI: calculator / QR-payment / printing screens only — no virtual
// keypad, per the product spec. Uses GxEPD2 against a Waveshare 2.9" panel.
//
// PANEL CONTROLLER: Waveshare has shipped multiple 2.9" revisions (IL3820,
// SSD1608, SSD1680...). GxEPD2_290_BS below targets the common SSD1680-based
// "2.9 V2" module. VERIFY AGAINST DATASHEET / your physical module's silkscreen
// or product page, and swap the GxEPD2 class if yours differs.
#pragma once
#include <Arduino.h>
#include <GxEPD2_BW.h>
#include "../include/pins.h"

class DisplayUI {
public:
    void begin();
    void showCalculator(const String& expression, double total, bool bleConnected);
    void showQrPayment(const String& upiUri, double amount);
    void showPrinting(double amount);
    void showError(const String& message);

private:
    // CS/DC/RST/BUSY come from pins.h (the hardware GPIO map), not hardcoded here.
    GxEPD2_BW<GxEPD2_290_BS, GxEPD2_290_BS::HEIGHT> display{
        GxEPD2_290_BS(PIN_EPD_CS, PIN_EPD_DC, PIN_EPD_RST, PIN_EPD_BUSY)
    };
};

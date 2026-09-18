#include "DisplayUI.h"
#include <SPI.h>
#include <qrcode.h>

void DisplayUI::begin() {
    SPI.begin(PIN_EPD_CLK, /*MISO unused*/ -1, PIN_EPD_MOSI, PIN_EPD_CS);
    display.init(115200, true, 2, false);
    display.setRotation(1); // landscape, 296x128
    display.setTextColor(GxEPD_BLACK);
}

void DisplayUI::showCalculator(const String& expression, double total, bool bleConnected) {
    display.setFullWindow();
    display.firstPage();
    do {
        display.fillScreen(GxEPD_WHITE);
        display.setCursor(4, 14);
        display.print("CALC");
        display.setCursor(240, 14);
        display.print(bleConnected ? "BLE *" : "BLE");
        display.drawFastHLine(0, 20, 296, GxEPD_BLACK);

        display.setCursor(4, 50);
        display.print(expression);

        char buf[24];
        snprintf(buf, sizeof(buf), "Rs %.2f", total);
        display.setCursor(150, 80);
        display.print(buf);

        display.drawFastHLine(0, 100, 296, GxEPD_BLACK);
        display.setCursor(4, 118);
        display.print("TOTAL");
        display.setCursor(180, 118);
        display.print(buf);
    } while (display.nextPage());
}

void DisplayUI::showQrPayment(const String& upiUri, double amount) {
    QRCode qrcode;
    uint8_t qrData[qrcode_getBufferSize(6)];
    qrcode_initText(&qrcode, qrData, 6, ECC_MEDIUM, upiUri.c_str());

    const int originX = (296 - qrcode.size * 3) / 2;
    const int originY = 20;

    display.setFullWindow();
    display.firstPage();
    do {
        display.fillScreen(GxEPD_WHITE);
        display.setCursor(90, 14);
        display.print("SCAN TO PAY");

        for (uint8_t y = 0; y < qrcode.size; y++) {
            for (uint8_t x = 0; x < qrcode.size; x++) {
                if (qrcode_getModule(&qrcode, x, y)) {
                    display.fillRect(originX + x * 3, originY + y * 3, 3, 3, GxEPD_BLACK);
                }
            }
        }

        char buf[24];
        snprintf(buf, sizeof(buf), "Rs %.2f", amount);
        display.setCursor(100, 122);
        display.print(buf);
    } while (display.nextPage());
}

void DisplayUI::showPrinting(double amount) {
    display.setFullWindow();
    display.firstPage();
    do {
        display.fillScreen(GxEPD_WHITE);
        display.setCursor(90, 20);
        display.print("PRINTING...");

        char buf[24];
        snprintf(buf, sizeof(buf), "Rs %.2f", amount);
        display.setCursor(100, 122);
        display.print(buf);
    } while (display.nextPage());
}

void DisplayUI::showError(const String& message) {
    display.setFullWindow();
    display.firstPage();
    do {
        display.fillScreen(GxEPD_WHITE);
        display.setCursor(4, 14);
        display.print("ERROR");
        display.drawFastHLine(0, 20, 296, GxEPD_BLACK);
        display.setCursor(4, 50);
        display.print(message);
    } while (display.nextPage());
}

// Calc2Pay firmware — entry point.
// Wires together: keypad -> calculator -> e-paper, QR generation, thermal
// printing, buzzer/LED feedback, and a BLE merchant-config service.
// GPIO source of truth: ../include/pins.h (mirrors ../../hardware/03-GPIO-MAP.md).
#include <Arduino.h>
#include "Keypad.h"
#include "Calculator.h"
#include "DisplayUI.h"
#include "Printer.h"
#include "Feedback.h"
#include "MerchantConfig.h"
#include "BleService.h"
#include "../include/pins.h"

Keypad keypad;
Calculator calculator;
DisplayUI displayUI;
Printer printer;
Feedback feedback;
MerchantConfig merchantConfig;
BleService bleService;

static void buildUpiUri(char* out, size_t outSize, double amount) {
    // upi://pay?pa=<vpa>&pn=<name>&am=<amount>&cu=INR
    snprintf(out, outSize, "upi://pay?pa=%s&pn=%s&am=%.2f&cu=INR",
             merchantConfig.vpa.c_str(), merchantConfig.businessName.c_str(), amount);
}

void setup() {
    Serial.begin(115200); // native USB CDC console

    pinMode(PIN_USER_BUTTON, INPUT_PULLUP);

    merchantConfig.load();
    feedback.begin();
    keypad.begin();
    displayUI.begin();
    printer.begin();
    bleService.begin(&merchantConfig);

    calculator.setGstPercent(merchantConfig.gstPercent);
    calculator.setDiscountPercent(merchantConfig.discountPercent);

    feedback.setLed(LedState::READY);
    displayUI.showCalculator(calculator.expressionText(), calculator.total(), false);

    Serial.println("Calc2Pay firmware boot OK");
}

void loop() {
    static bool wasConnected = false;
    bool connected = bleService.isConnected();
    if (connected != wasConnected) {
        feedback.setLed(connected ? LedState::BLE_CONNECTED : LedState::READY);
        wasConnected = connected;
    }

    Key key = keypad.scan();
    if (key == Key::NONE) {
        delay(5); // matrix scan is cheap; this just caps loop rate
        return;
    }

    feedback.beepKeyPress();

    if (key == Key::QR) {
        feedback.setLed(LedState::PROCESSING);
        double amount = calculator.total();
        char uri[128];
        buildUpiUri(uri, sizeof(uri), amount);
        displayUI.showQrPayment(String(uri), amount);
        feedback.beepQrGenerated();
        bleService.notifyStatus("qr");
        feedback.setLed(connected ? LedState::BLE_CONNECTED : LedState::READY);
        return;
    }

    if (key == Key::PRINT) {
        feedback.setLed(LedState::PROCESSING);
        double subtotal = calculator.result();
        double total = calculator.total();
        displayUI.showPrinting(total);
        feedback.beepPrintStarted();
        bleService.notifyStatus("printing");

        printer.printReceipt(merchantConfig.businessName, calculator.expressionText(),
                              subtotal, merchantConfig.gstPercent,
                              merchantConfig.discountPercent, total);

        feedback.beepPrintComplete();
        feedback.setLed(LedState::SUCCESS);
        bleService.notifyStatus("idle");
        delay(400);
        displayUI.showCalculator(calculator.expressionText(), calculator.total(), connected);
        feedback.setLed(connected ? LedState::BLE_CONNECTED : LedState::READY);
        return;
    }

    bool changed = calculator.handleKey(key);
    if (calculator.hasError()) {
        feedback.beepError();
        feedback.setLed(LedState::ERROR);
        displayUI.showError("Cannot divide by zero");
        return;
    }
    if (changed) {
        displayUI.showCalculator(calculator.expressionText(), calculator.total(), connected);
    }
}

#include "Feedback.h"
#include "../include/pins.h"

void Feedback::begin() {
    pinMode(PIN_BUZZER, OUTPUT);
    digitalWrite(PIN_BUZZER, LOW);
    pinMode(PIN_LED_R, OUTPUT);
    pinMode(PIN_LED_G, OUTPUT);
    pinMode(PIN_LED_B, OUTPUT);
    setRgb(false, false, false);
}

void Feedback::setRgb(bool r, bool g, bool b) {
    digitalWrite(PIN_LED_R, r ? HIGH : LOW);
    digitalWrite(PIN_LED_G, g ? HIGH : LOW);
    digitalWrite(PIN_LED_B, b ? HIGH : LOW);
}

void Feedback::setLed(LedState state) {
    switch (state) {
        case LedState::READY:         setRgb(false, true,  false); break; // GREEN
        case LedState::BLE_CONNECTED: setRgb(false, false, true);  break; // BLUE
        case LedState::PROCESSING:    setRgb(true,  true,  false); break; // YELLOW
        case LedState::SUCCESS:       setRgb(false, true,  false); break; // GREEN
        case LedState::ERROR:         setRgb(true,  false, false); break; // RED
        case LedState::OFF:           setRgb(false, false, false); break;
    }
}

void Feedback::beep(uint16_t durationMs, uint16_t count) {
    for (uint16_t i = 0; i < count; i++) {
        digitalWrite(PIN_BUZZER, HIGH);
        delay(durationMs);
        digitalWrite(PIN_BUZZER, LOW);
        if (i + 1 < count) delay(durationMs);
    }
}

void Feedback::beepKeyPress()      { beep(15, 1); }
void Feedback::beepQrGenerated()   { beep(80, 1); }
void Feedback::beepPrintStarted()  { beep(50, 2); }
void Feedback::beepPrintComplete() { beep(150, 1); }
void Feedback::beepError()         { beep(300, 2); }

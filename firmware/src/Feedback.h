// Buzzer + status RGB LED. GPIO drives a transistor for the buzzer (never
// direct-drive a high-current load from a GPIO) and drives the RGB LED
// through current-limit resistors — see hardware/04-SCHEMATIC-CONNECTIONS.md.
#pragma once
#include <Arduino.h>

enum class LedState { READY, BLE_CONNECTED, PROCESSING, SUCCESS, ERROR, OFF };

class Feedback {
public:
    void begin();
    void setLed(LedState state);

    void beepKeyPress();
    void beepQrGenerated();
    void beepPrintStarted();
    void beepPrintComplete();
    void beepError();

private:
    void beep(uint16_t durationMs, uint16_t count = 1);
    void setRgb(bool r, bool g, bool b);
};

#include "Keypad.h"
#include "../include/pins.h"

const Key Keypad::layout[ROWS][COLS] = {
    { Key::K7, Key::K8, Key::K9, Key::DIV,   Key::CLR   },
    { Key::K4, Key::K5, Key::K6, Key::MUL,   Key::DEL   },
    { Key::K1, Key::K2, Key::K3, Key::MINUS, Key::QR    },
    { Key::K0, Key::DOT,Key::EQUALS, Key::PLUS, Key::PRINT },
};

void Keypad::begin() {
    rowPins[0] = PIN_KEY_R1; rowPins[1] = PIN_KEY_R2;
    rowPins[2] = PIN_KEY_R3; rowPins[3] = PIN_KEY_R4;
    colPins[0] = PIN_KEY_C1; colPins[1] = PIN_KEY_C2;
    colPins[2] = PIN_KEY_C3; colPins[3] = PIN_KEY_C4; colPins[4] = PIN_KEY_C5;

    for (uint8_t r = 0; r < ROWS; r++) {
        pinMode(rowPins[r], OUTPUT);
        digitalWrite(rowPins[r], HIGH); // idle high, active-low scan
    }
    for (uint8_t c = 0; c < COLS; c++) {
        pinMode(colPins[c], INPUT_PULLUP); // internal pull-up, no external resistor needed
    }
}

Key Keypad::scan() {
    uint32_t now = millis();
    Key pressed = Key::NONE;

    for (uint8_t r = 0; r < ROWS; r++) {
        digitalWrite(rowPins[r], LOW);
        delayMicroseconds(5); // let the line settle before sampling columns

        for (uint8_t c = 0; c < COLS; c++) {
            bool raw = (digitalRead(colPins[c]) == LOW); // pressed = pulled low

            if (raw != lastState[r][c]) {
                lastState[r][c] = raw;
                lastChangeMs[r][c] = now;
            } else if ((now - lastChangeMs[r][c]) > DEBOUNCE_MS) {
                if (raw != debouncedState[r][c]) {
                    debouncedState[r][c] = raw;
                    if (raw && pressed == Key::NONE) {
                        pressed = layout[r][c]; // rising edge = new keypress
                    }
                }
            }
        }

        digitalWrite(rowPins[r], HIGH);
    }

    return pressed;
}

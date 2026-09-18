// 4x5 matrix keypad scanner with software debounce. Direct GPIO scan, no
// controller IC — see ../../hardware/01-DESIGN-REVIEW.md section 6 for why.
#pragma once
#include <Arduino.h>

enum class Key : uint8_t {
    NONE, K0, K1, K2, K3, K4, K5, K6, K7, K8, K9,
    DOT, PLUS, MINUS, MUL, DIV, EQUALS,
    CLR, DEL, QR, PRINT
};

class Keypad {
public:
    void begin();
    // Returns the newly pressed key this call (debounced, edge-triggered),
    // or Key::NONE if nothing new was pressed. Call frequently from loop().
    Key scan();

private:
    static const uint8_t ROWS = 4;
    static const uint8_t COLS = 5;
    uint8_t rowPins[ROWS];
    uint8_t colPins[COLS];

    // Logical key layout, matches hardware/00 spec's physical keypad legend:
    //   7 8 9 / CLR
    //   4 5 6 x DEL
    //   1 2 3 - QR
    //   0 . = + PRINT
    static const Key layout[ROWS][COLS];

    bool lastState[ROWS][COLS] = {};
    bool debouncedState[ROWS][COLS] = {};
    uint32_t lastChangeMs[ROWS][COLS] = {};
    static const uint32_t DEBOUNCE_MS = 25;
};

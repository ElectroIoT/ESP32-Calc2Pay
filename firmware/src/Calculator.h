// Simple running-total calculator: single pending operator, no operator
// precedence/parentheses (matches a physical calculator, not a math parser).
// Also applies GST% and discount% from merchant config to the running total.
#pragma once
#include <Arduino.h>
#include "Keypad.h"

class Calculator {
public:
    void reset();
    // Feed one key press. Returns true if the display should be redrawn.
    bool handleKey(Key k);

    String expressionText() const;   // e.g. "1250 + 350"
    double result() const { return currentValue; }
    double total() const { return totalValue; }   // result with GST/discount applied
    bool hasError() const { return error; }

    void setGstPercent(double pct) { gstPercent = pct; }
    void setDiscountPercent(double pct) { discountPercent = pct; }

private:
    String entryBuffer = "0";
    double accumulator = 0;
    char pendingOp = 0; // '+','-','*','/', or 0 if none
    double currentValue = 0;
    double totalValue = 0;
    double gstPercent = 0;
    double discountPercent = 0;
    bool error = false;
    bool freshEntry = true; // next digit starts a new number

    void appendDigit(char c);
    void applyOperator(char op);
    void equals();
    void recomputeTotal();
};

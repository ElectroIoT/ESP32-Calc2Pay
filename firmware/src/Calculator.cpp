#include "Calculator.h"

void Calculator::reset() {
    entryBuffer = "0";
    accumulator = 0;
    pendingOp = 0;
    currentValue = 0;
    totalValue = 0;
    error = false;
    freshEntry = true;
}

void Calculator::appendDigit(char c) {
    if (error) reset();
    if (freshEntry) {
        entryBuffer = "";
        freshEntry = false;
    }
    if (c == '.' && entryBuffer.indexOf('.') >= 0) return; // one decimal point max
    if (entryBuffer == "0" && c != '.') entryBuffer = "";
    entryBuffer += c;
    currentValue = entryBuffer.toDouble();
}

void Calculator::applyOperator(char op) {
    if (error) return;
    if (pendingOp != 0 && !freshEntry) {
        equals();
    } else {
        accumulator = entryBuffer.toDouble();
    }
    pendingOp = op;
    freshEntry = true;
}

void Calculator::equals() {
    double rhs = entryBuffer.toDouble();
    switch (pendingOp) {
        case '+': accumulator += rhs; break;
        case '-': accumulator -= rhs; break;
        case '*': accumulator *= rhs; break;
        case '/':
            if (rhs == 0) { error = true; return; }
            accumulator /= rhs;
            break;
        default: accumulator = rhs; break;
    }
    currentValue = accumulator;
    entryBuffer = String(accumulator);
    pendingOp = 0;
    freshEntry = true;
    recomputeTotal();
}

void Calculator::recomputeTotal() {
    double withDiscount = currentValue * (1.0 - discountPercent / 100.0);
    totalValue = withDiscount * (1.0 + gstPercent / 100.0);
}

bool Calculator::handleKey(Key k) {
    switch (k) {
        case Key::K0: appendDigit('0'); return true;
        case Key::K1: appendDigit('1'); return true;
        case Key::K2: appendDigit('2'); return true;
        case Key::K3: appendDigit('3'); return true;
        case Key::K4: appendDigit('4'); return true;
        case Key::K5: appendDigit('5'); return true;
        case Key::K6: appendDigit('6'); return true;
        case Key::K7: appendDigit('7'); return true;
        case Key::K8: appendDigit('8'); return true;
        case Key::K9: appendDigit('9'); return true;
        case Key::DOT: appendDigit('.'); return true;

        case Key::PLUS:  applyOperator('+'); return true;
        case Key::MINUS: applyOperator('-'); return true;
        case Key::MUL:   applyOperator('*'); return true;
        case Key::DIV:   applyOperator('/'); return true;

        case Key::EQUALS: equals(); return true;

        case Key::CLR: reset(); return true;
        case Key::DEL:
            if (!freshEntry && entryBuffer.length() > 1) {
                entryBuffer.remove(entryBuffer.length() - 1);
            } else {
                entryBuffer = "0";
                freshEntry = true;
            }
            currentValue = entryBuffer.toDouble();
            return true;

        default:
            return false; // QR/PRINT handled by main.cpp, not the calculator
    }
}

String Calculator::expressionText() const {
    if (pendingOp == 0) return entryBuffer;
    String opStr;
    switch (pendingOp) {
        case '+': opStr = "+"; break;
        case '-': opStr = "-"; break;
        case '*': opStr = "x"; break;
        case '/': opStr = "/"; break;
    }
    return String(accumulator) + " " + opStr + " " + (freshEntry ? "" : entryBuffer);
}

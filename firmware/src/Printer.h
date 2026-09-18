// 58mm TTL thermal printer driver over UART. Sends plain ESC/POS-subset
// commands. Exact supported command set depends on the physical printer
// module — VERIFY AGAINST DATASHEET (see ../../hardware/06-BOM.md sourcing
// notes). This implementation sticks to the near-universal minimum: plain
// text + line feed + paper cut/feed, which almost every 58mm TTL module
// supports even without full ESC/POS compliance.
#pragma once
#include <Arduino.h>

class Printer {
public:
    void begin();
    void printReceipt(const String& merchantName, const String& expression,
                       double subtotal, double gstPercent, double discountPercent,
                       double total);

private:
    HardwareSerial serial{1}; // UART1, distinct from the USB CDC console (UART0)
    void feedLines(uint8_t n);
};

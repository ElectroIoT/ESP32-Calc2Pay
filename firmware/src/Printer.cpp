#include "Printer.h"
#include "../include/pins.h"

void Printer::begin() {
    serial.begin(9600, SERIAL_8N1, PIN_PRINTER_RX, PIN_PRINTER_TX);
    // 9600 baud is the common default for cheap 58mm TTL modules.
    // VERIFY AGAINST DATASHEET — some modules default to 19200/115200.
}

void Printer::feedLines(uint8_t n) {
    for (uint8_t i = 0; i < n; i++) serial.write('\n');
}

void Printer::printReceipt(const String& merchantName, const String& expression,
                            double subtotal, double gstPercent, double discountPercent,
                            double total) {
    char line[48];

    feedLines(1);
    serial.println(merchantName);
    serial.println("--------------------------------");
    serial.println(expression);

    snprintf(line, sizeof(line), "Subtotal:   Rs %10.2f", subtotal);
    serial.println(line);

    if (discountPercent > 0) {
        snprintf(line, sizeof(line), "Discount %4.1f%%:  -Rs %8.2f", discountPercent,
                 subtotal * discountPercent / 100.0);
        serial.println(line);
    }
    if (gstPercent > 0) {
        snprintf(line, sizeof(line), "GST %4.1f%%:       Rs %8.2f", gstPercent,
                 subtotal * (1 - discountPercent / 100.0) * gstPercent / 100.0);
        serial.println(line);
    }

    serial.println("--------------------------------");
    snprintf(line, sizeof(line), "TOTAL:      Rs %10.2f", total);
    serial.println(line);
    serial.println("--------------------------------");
    serial.println("Calc2Pay - Calculate.Pay.Print");

    feedLines(4); // clear the print head before any (future) manual/auto cutter
}

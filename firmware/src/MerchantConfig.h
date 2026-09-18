// Merchant configuration persisted in NVS (flash). Not committed to source,
// not logged in plaintext at runtime beyond what's needed for BLE transfer.
// Full flash encryption is deferred to Rev-2 — see ../CLAUDE.md rule 5/6.
#pragma once
#include <Arduino.h>

struct MerchantConfig {
    String vpa = "merchant@upi";
    String businessName = "Calc2Pay";
    double gstPercent = 0.0;
    double discountPercent = 0.0;

    void load();
    void save() const;
    String toJson() const;
    bool fromJson(const String& json); // returns false on parse failure
};

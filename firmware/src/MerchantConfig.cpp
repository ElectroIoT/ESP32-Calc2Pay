#include "MerchantConfig.h"
#include <Preferences.h>
#include <ArduinoJson.h>

static const char* NVS_NAMESPACE = "c2p_merchant";

void MerchantConfig::load() {
    Preferences prefs;
    prefs.begin(NVS_NAMESPACE, /*readOnly=*/true);
    vpa = prefs.getString("vpa", vpa);
    businessName = prefs.getString("name", businessName);
    gstPercent = prefs.getDouble("gst", gstPercent);
    discountPercent = prefs.getDouble("disc", discountPercent);
    prefs.end();
}

void MerchantConfig::save() const {
    Preferences prefs;
    prefs.begin(NVS_NAMESPACE, /*readOnly=*/false);
    prefs.putString("vpa", vpa);
    prefs.putString("name", businessName);
    prefs.putDouble("gst", gstPercent);
    prefs.putDouble("disc", discountPercent);
    prefs.end();
}

String MerchantConfig::toJson() const {
    JsonDocument doc;
    doc["vpa"] = vpa;
    doc["name"] = businessName;
    doc["gst_percent"] = gstPercent;
    doc["discount_percent"] = discountPercent;
    String out;
    serializeJson(doc, out);
    return out;
}

bool MerchantConfig::fromJson(const String& json) {
    JsonDocument doc;
    DeserializationError err = deserializeJson(doc, json);
    if (err) return false;

    if (doc["vpa"].is<const char*>()) vpa = doc["vpa"].as<String>();
    if (doc["name"].is<const char*>()) businessName = doc["name"].as<String>();
    if (doc["gst_percent"].is<double>()) gstPercent = doc["gst_percent"].as<double>();
    if (doc["discount_percent"].is<double>()) discountPercent = doc["discount_percent"].as<double>();
    return true;
}

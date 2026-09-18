#include "BleService.h"
#include "../include/ble_uuids.h"

namespace {

MerchantConfig* g_merchantConfig = nullptr;
NimBLECharacteristic* g_merchantCfgChar = nullptr;

// IMPORTANT: always call setValue() with an explicit std::string, never a
// bare `const char*` (from String::c_str() or a string literal). NimBLE-
// Arduino's setValue() has a templated overload for trivial/POD types
// alongside the string-copying overloads; a `const char*` argument can bind
// to that POD template instead, which stores the raw pointer VALUE (4 or 8
// bytes) as the characteristic's binary content rather than copying the
// string it points to. This was a real, reproduced bug: the merchant-config
// characteristic was returning a 4-byte stack/heap address instead of JSON.
std::string toStdString(const String& s) {
    return std::string(s.c_str(), s.length());
}

class MerchantCfgCallbacks : public NimBLECharacteristicCallbacks {
    void onWrite(NimBLECharacteristic* chr) override {
        if (!g_merchantConfig) return;
        String json = String(chr->getValue().c_str());
        if (g_merchantConfig->fromJson(json)) {
            g_merchantConfig->save();
        }
        // Echo the (possibly clamped/normalized) stored config back so the
        // app can confirm what was actually persisted.
        chr->setValue(toStdString(g_merchantConfig->toJson()));
    }
};

} // namespace

void BleService::begin(MerchantConfig* config) {
    merchantConfig = config;
    g_merchantConfig = config;

    NimBLEDevice::init(C2P_BLE_DEVICE_NAME);
    server = NimBLEDevice::createServer();

    NimBLEService* service = server->createService(C2P_SERVICE_UUID);

    merchantCfgChar = service->createCharacteristic(
        C2P_CHAR_MERCHANT_CFG_UUID,
        NIMBLE_PROPERTY::READ | NIMBLE_PROPERTY::WRITE);
    merchantCfgChar->setCallbacks(new MerchantCfgCallbacks());
    merchantCfgChar->setValue(toStdString(merchantConfig->toJson()));
    g_merchantCfgChar = merchantCfgChar;

    statusChar = service->createCharacteristic(
        C2P_CHAR_STATUS_UUID,
        NIMBLE_PROPERTY::READ | NIMBLE_PROPERTY::NOTIFY);
    statusChar->setValue(toStdString("{\"fw_version\":\"0.1.0\",\"state\":\"idle\"}"));

    deviceIdChar = service->createCharacteristic(
        C2P_CHAR_DEVICE_ID_UUID,
        NIMBLE_PROPERTY::READ);
    deviceIdChar->setValue(NimBLEDevice::getAddress().toString());

    service->start();

    NimBLEAdvertising* advertising = NimBLEDevice::getAdvertising();
    advertising->addServiceUUID(C2P_SERVICE_UUID);
    advertising->start();
}

bool BleService::isConnected() const {
    return server && server->getConnectedCount() > 0;
}

void BleService::notifyStatus(const String& state) {
    if (!statusChar) return;
    String json = String("{\"fw_version\":\"0.1.0\",\"state\":\"") + state + "\"}";
    statusChar->setValue(toStdString(json));
    statusChar->notify();
}

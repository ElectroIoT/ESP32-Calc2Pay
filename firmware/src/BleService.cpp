#include "BleService.h"
#include "../include/ble_uuids.h"

namespace {

MerchantConfig* g_merchantConfig = nullptr;
NimBLECharacteristic* g_merchantCfgChar = nullptr;

class MerchantCfgCallbacks : public NimBLECharacteristicCallbacks {
    void onWrite(NimBLECharacteristic* chr) override {
        if (!g_merchantConfig) return;
        String json = String(chr->getValue().c_str());
        if (g_merchantConfig->fromJson(json)) {
            g_merchantConfig->save();
        }
        // Echo the (possibly clamped/normalized) stored config back so the
        // app can confirm what was actually persisted.
        chr->setValue(g_merchantConfig->toJson().c_str());
    }

    void onRead(NimBLECharacteristic* chr) override {
        if (g_merchantConfig) {
            chr->setValue(g_merchantConfig->toJson().c_str());
        }
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
    merchantCfgChar->setValue(merchantConfig->toJson().c_str());
    g_merchantCfgChar = merchantCfgChar;

    statusChar = service->createCharacteristic(
        C2P_CHAR_STATUS_UUID,
        NIMBLE_PROPERTY::READ | NIMBLE_PROPERTY::NOTIFY);
    statusChar->setValue("{\"fw_version\":\"0.1.0\",\"state\":\"idle\"}");

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
    statusChar->setValue(json.c_str());
    statusChar->notify();
}

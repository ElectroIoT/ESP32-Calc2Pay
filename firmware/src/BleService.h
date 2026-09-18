// BLE GATT peripheral exposing merchant config (read/write) and device
// status (read/notify). UUIDs are the cross-project contract in
// ../include/ble_uuids.h — the companion app (../../app/) depends on them.
#pragma once
#include <Arduino.h>
#include <NimBLEDevice.h>
#include "MerchantConfig.h"

class BleService {
public:
    void begin(MerchantConfig* config);
    bool isConnected() const;
    void notifyStatus(const String& state);

private:
    MerchantConfig* merchantConfig = nullptr;
    NimBLEServer* server = nullptr;
    NimBLECharacteristic* merchantCfgChar = nullptr;
    NimBLECharacteristic* statusChar = nullptr;
    NimBLECharacteristic* deviceIdChar = nullptr;
};

// Calc2Pay BLE GATT contract — SOURCE OF TRUTH for both firmware and the
// companion app (../../app/). If you change a UUID here, update
// ../../app/MEMORY.md's allocation table in the same change.
#pragma once

// Custom 128-bit base UUID, randomly generated for this project (not a
// standard SIG service — Calc2Pay is a proprietary/custom GATT profile).
#define C2P_SERVICE_UUID           "c2f5e000-3a9b-4b7e-8f21-6d1a2c3e4f50"

// Merchant configuration (read/write, plain UTF-8 JSON payload):
// { "vpa": "merchant@upi", "name": "My Shop", "gst_percent": 18.0, "discount_percent": 0.0 }
#define C2P_CHAR_MERCHANT_CFG_UUID "c2f5e001-3a9b-4b7e-8f21-6d1a2c3e4f50"

// Device status (read/notify, plain UTF-8 JSON payload):
// { "fw_version": "0.1.0", "state": "idle|calculating|qr|printing|error", "battery": null }
#define C2P_CHAR_STATUS_UUID       "c2f5e002-3a9b-4b7e-8f21-6d1a2c3e4f50"

// Device info (read-only, plain UTF-8): unique device ID derived from the
// ESP32-S3's factory MAC address, used by the app to tell multiple Calc2Pay
// units apart.
#define C2P_CHAR_DEVICE_ID_UUID    "c2f5e003-3a9b-4b7e-8f21-6d1a2c3e4f50"

#define C2P_BLE_DEVICE_NAME        "Calc2Pay"

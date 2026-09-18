// Calc2Pay BLE GATT contract.
//
// SOURCE OF TRUTH: ../../firmware/include/ble_uuids.h — these must match
// exactly. If firmware changes a UUID, update this file in the same change
// (see ../../CLAUDE.md rule on keeping firmware<->app in sync).

class Calc2PayBleUuids {
  Calc2PayBleUuids._();

  static const String serviceUuid = 'c2f5e000-3a9b-4b7e-8f21-6d1a2c3e4f50';

  /// Read/write. Plain UTF-8 JSON:
  /// { "vpa": "merchant@upi", "name": "My Shop", "gst_percent": 18.0, "discount_percent": 0.0 }
  static const String merchantConfigCharUuid =
      'c2f5e001-3a9b-4b7e-8f21-6d1a2c3e4f50';

  /// Read/notify. Plain UTF-8 JSON:
  /// { "fw_version": "0.1.0", "state": "idle|calculating|qr|printing|error" }
  static const String statusCharUuid = 'c2f5e002-3a9b-4b7e-8f21-6d1a2c3e4f50';

  /// Read-only. Plain UTF-8 string (device's BLE MAC address).
  static const String deviceIdCharUuid =
      'c2f5e003-3a9b-4b7e-8f21-6d1a2c3e4f50';

  static const String advertisedDeviceName = 'Calc2Pay';
}

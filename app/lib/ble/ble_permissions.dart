import 'package:permission_handler/permission_handler.dart';

/// Shared by both BLE screens (Calc2Pay device + generic printer) — requests
/// runtime BLE permissions and reports success.
///
/// Only bluetoothScan/bluetoothConnect actually gate BLE on Android 12+ (the
/// manifest declares BLUETOOTH_SCAN with neverForLocation, so no location
/// permission is needed there). locationWhenInUse is only relevant on
/// pre-12 devices for scan results to come back; on 12+ devices requesting
/// it can report "denied" simply because it's excluded via maxSdkVersion in
/// the manifest for that API level — that must not block the flow.
Future<bool> requestBlePermissions() async {
  final statuses = await [
    Permission.bluetoothScan,
    Permission.bluetoothConnect,
    Permission.locationWhenInUse,
  ].request();

  bool okOrMissing(Permission p) {
    final status = statuses[p];
    return status == null || status.isGranted || status.isLimited;
  }

  return okOrMissing(Permission.bluetoothScan) &&
      okOrMissing(Permission.bluetoothConnect);
}

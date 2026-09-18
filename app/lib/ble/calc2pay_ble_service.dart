import 'dart:async';
import 'dart:convert';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../models/device_status.dart';
import '../models/merchant_config.dart';
import 'calc2pay_ble_uuids.dart';

/// Thin wrapper around flutter_blue_plus scoped to exactly what the Calc2Pay
/// GATT service exposes. Deliberately does not try to be a general BLE
/// abstraction — see ../../app/README.md for Rev-1 scope (no accounts, no
/// cloud, device-local config only).
class Calc2PayBleService {
  Calc2PayBleService._();
  static final Calc2PayBleService instance = Calc2PayBleService._();

  BluetoothDevice? _device;
  BluetoothCharacteristic? _merchantConfigChar;
  BluetoothCharacteristic? _statusChar;
  BluetoothCharacteristic? _deviceIdChar;
  StreamSubscription<List<int>>? _statusSub;

  final _statusController = StreamController<DeviceStatus>.broadcast();
  Stream<DeviceStatus> get statusStream => _statusController.stream;

  BluetoothDevice? get connectedDevice => _device;

  bool get isConnected =>
      _device?.isConnected ?? false;

  /// BLE characteristic reads/notifications on this device have been
  /// observed to carry a trailing null byte after the actual payload (a
  /// known class of quirk: some GATT stacks pad odd-length attribute values
  /// to an even byte count). A 37-byte JSON payload arrives as 38 bytes with
  /// a trailing 0x00, which breaks `jsonDecode` with a "FormatException:
  /// Unexpected character" at the tail. Stripping trailing NUL bytes before
  /// decoding fixes this regardless of which layer (Android's GATT stack,
  /// the plugin, or the firmware) actually adds the padding.
  static List<int> _stripTrailingNulls(List<int> bytes) {
    var end = bytes.length;
    while (end > 0 && bytes[end - 1] == 0) {
      end--;
    }
    return end == bytes.length ? bytes : bytes.sublist(0, end);
  }

  /// Scans for devices advertising the Calc2Pay service UUID.
  /// Caller is responsible for BLE/location permissions (see permission
  /// handling in screens/scan_screen.dart) before calling this.
  Stream<List<ScanResult>> scanForDevices({
    Duration timeout = const Duration(seconds: 8),
  }) {
    FlutterBluePlus.startScan(
      withServices: [Guid(Calc2PayBleUuids.serviceUuid)],
      timeout: timeout,
    );
    return FlutterBluePlus.scanResults;
  }

  Future<void> stopScan() => FlutterBluePlus.stopScan();

  Future<void> connect(BluetoothDevice device) async {
    await device.connect(timeout: const Duration(seconds: 10));
    _device = device;

    final services = await device.discoverServices();
    final calc2payService = services.firstWhere(
      (s) => s.uuid.toString().toLowerCase() ==
          Calc2PayBleUuids.serviceUuid.toLowerCase(),
      orElse: () => throw StateError(
        'Connected device does not expose the Calc2Pay GATT service — '
        'is this actually a Calc2Pay device?',
      ),
    );

    for (final c in calc2payService.characteristics) {
      final uuid = c.uuid.toString().toLowerCase();
      if (uuid == Calc2PayBleUuids.merchantConfigCharUuid.toLowerCase()) {
        _merchantConfigChar = c;
      } else if (uuid == Calc2PayBleUuids.statusCharUuid.toLowerCase()) {
        _statusChar = c;
      } else if (uuid == Calc2PayBleUuids.deviceIdCharUuid.toLowerCase()) {
        _deviceIdChar = c;
      }
    }

    if (_statusChar != null) {
      await _statusChar!.setNotifyValue(true);
      _statusSub = _statusChar!.onValueReceived.listen((bytes) {
        try {
          _statusController.add(
            DeviceStatus.fromJsonString(utf8.decode(_stripTrailingNulls(bytes))),
          );
        } catch (_) {
          // Malformed/partial notification — ignore rather than crash the UI.
        }
      });
    }
  }

  Future<void> disconnect() async {
    await _statusSub?.cancel();
    _statusSub = null;
    await _device?.disconnect();
    _device = null;
    _merchantConfigChar = null;
    _statusChar = null;
    _deviceIdChar = null;
  }

  /// BLE GATT only allows one outstanding request at a time per connection —
  /// issuing two reads/writes concurrently (e.g. from separate unawaited
  /// Future chains) can cause one to hang forever, since its response can be
  /// misrouted to the other pending request on some platform BLE stacks.
  /// Every read/write in this class funnels through this to guarantee they
  /// never overlap, and a request that stalls anyway surfaces as a
  /// TimeoutException rather than hanging silently.
  Future<T> _serialized<T>(Future<T> Function() operation) {
    final result = _gattQueue.then((_) => operation().timeout(
          const Duration(seconds: 8),
          onTimeout: () => throw TimeoutException(
            'BLE operation timed out — device may be out of range or busy.',
          ),
        ));
    // Swallow errors in the chained queue itself (they still propagate to
    // the caller via `result`) so one failed op doesn't jam the queue.
    _gattQueue = result.then((_) {}, onError: (_) {});
    return result;
  }

  Future<void> _gattQueue = Future.value();

  Future<MerchantConfig> readMerchantConfig() {
    return _serialized(() async {
      final char = _merchantConfigChar;
      if (char == null) {
        throw StateError('Not connected to a Calc2Pay device.');
      }
      final bytes = await char.read();
      return MerchantConfig.fromJsonString(utf8.decode(_stripTrailingNulls(bytes)));
    });
  }

  Future<void> writeMerchantConfig(MerchantConfig config) {
    return _serialized(() async {
      final char = _merchantConfigChar;
      if (char == null) {
        throw StateError('Not connected to a Calc2Pay device.');
      }
      await char.write(utf8.encode(config.toJsonString()), withoutResponse: false);
    });
  }

  /// Reads the status characteristic's current value directly, rather than
  /// waiting for a notification — firmware only pushes a notify on QR/Print
  /// actions (see ../../firmware/src/main.cpp), so relying on notify alone
  /// leaves the UI showing stale/unknown values right after connecting.
  Future<DeviceStatus> readStatus() {
    return _serialized(() async {
      final char = _statusChar;
      if (char == null) {
        throw StateError('Not connected to a Calc2Pay device.');
      }
      final bytes = await char.read();
      return DeviceStatus.fromJsonString(utf8.decode(_stripTrailingNulls(bytes)));
    });
  }

  Future<String> readDeviceId() {
    return _serialized(() async {
      final char = _deviceIdChar;
      if (char == null) return 'unknown';
      final bytes = await char.read();
      return utf8.decode(_stripTrailingNulls(bytes));
    });
  }
}

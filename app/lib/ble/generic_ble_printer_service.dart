import 'dart:async';
import 'dart:convert';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// Connects to a generic BLE thermal printer — NOT the Calc2Pay device.
///
/// Cheap BLE thermal printers (the common "portable receipt printer" class,
/// e.g. GOOJPRT/MPT-II/HM-10-based modules) don't share one standard GATT
/// profile the way the Calc2Pay device does — each vendor exposes its own
/// service/characteristic UUIDs. So instead of hardcoding one UUID, this
/// scans broadly, lets the user pick their printer by name, then picks the
/// first characteristic that supports WRITE or WRITE_WITHOUT_RESPONSE as the
/// print target. This is a heuristic, not a guarantee — some printers may
/// need a specific characteristic chosen manually (exposed via
/// [writableCharacteristics] for the UI to offer a manual picker).
class GenericBlePrinterService {
  GenericBlePrinterService._();
  static final GenericBlePrinterService instance = GenericBlePrinterService._();

  BluetoothDevice? _device;
  BluetoothCharacteristic? _writeChar;
  List<BluetoothCharacteristic> _writableCandidates = [];

  BluetoothDevice? get connectedDevice => _device;
  bool get isConnected => _device?.isConnected ?? false;
  List<BluetoothCharacteristic> get writableCharacteristics =>
      List.unmodifiable(_writableCandidates);
  BluetoothCharacteristic? get selectedCharacteristic => _writeChar;

  /// Broad scan (no service-UUID filter — printer UUIDs vary by vendor).
  /// Caller handles permissions the same way as for the Calc2Pay scan.
  Stream<List<ScanResult>> scanForPrinters({
    Duration timeout = const Duration(seconds: 8),
  }) {
    FlutterBluePlus.startScan(timeout: timeout);
    return FlutterBluePlus.scanResults;
  }

  Future<void> stopScan() => FlutterBluePlus.stopScan();

  /// Connects and discovers services, collecting every characteristic that
  /// can be written to. Auto-selects the first one found; call
  /// [selectCharacteristic] to override if the wrong one was picked.
  Future<void> connect(BluetoothDevice device) async {
    await device.connect(timeout: const Duration(seconds: 10));
    _device = device;

    final services = await device.discoverServices();
    _writableCandidates = [
      for (final s in services)
        for (final c in s.characteristics)
          if (c.properties.write || c.properties.writeWithoutResponse) c,
    ];
    _writeChar = _writableCandidates.isNotEmpty ? _writableCandidates.first : null;
  }

  void selectCharacteristic(BluetoothCharacteristic characteristic) {
    if (_writableCandidates.contains(characteristic)) {
      _writeChar = characteristic;
    }
  }

  Future<void> disconnect() async {
    await _device?.disconnect();
    _device = null;
    _writeChar = null;
    _writableCandidates = [];
  }

  /// Sends raw bytes (e.g. ESC/POS commands) to the selected characteristic.
  Future<void> printRaw(List<int> bytes) async {
    final char = _writeChar;
    if (char == null) {
      throw StateError('No BLE printer connected, or no writable characteristic found.');
    }
    // Most BLE printer modules only accept small MTU-sized chunks reliably —
    // split into ~180-byte pieces rather than sending one giant write.
    const chunkSize = 180;
    for (var offset = 0; offset < bytes.length; offset += chunkSize) {
      final end = (offset + chunkSize < bytes.length) ? offset + chunkSize : bytes.length;
      await char.write(
        bytes.sublist(offset, end),
        withoutResponse: char.properties.writeWithoutResponse,
      );
    }
  }

  /// Convenience: prints plain text (with a trailing feed) via ESC/POS.
  Future<void> printText(String text) async {
    final bytes = <int>[
      ...utf8.encode(text),
      0x0A, 0x0A, 0x0A, 0x0A, // feed a few lines so the receipt clears the head
    ];
    await printRaw(bytes);
  }
}

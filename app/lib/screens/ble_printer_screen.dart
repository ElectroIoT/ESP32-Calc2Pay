import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../ble/ble_permissions.dart';
import '../ble/generic_ble_printer_service.dart';

/// Connect to a generic Bluetooth (BLE) thermal printer — separate from the
/// Calc2Pay ESP32 device. Useful for portable BLE receipt printers that
/// don't go through the ESP32's own UART-wired printer (../../hardware/06-BOM.md).
/// Each vendor uses different GATT UUIDs, so this scans broadly and lets the
/// user pick both the device and (if needed) the write characteristic.
class BlePrinterScreen extends StatefulWidget {
  const BlePrinterScreen({super.key});

  @override
  State<BlePrinterScreen> createState() => _BlePrinterScreenState();
}

class _BlePrinterScreenState extends State<BlePrinterScreen> {
  final _printer = GenericBlePrinterService.instance;
  List<ScanResult> _results = [];
  bool _scanning = false;
  bool _connecting = false;
  bool _printing = false;
  String? _error;
  String? _connectedName;

  @override
  void dispose() {
    _printer.stopScan();
    super.dispose();
  }

  Future<void> _startScan() async {
    setState(() {
      _error = null;
      _results = [];
    });

    if (!await requestBlePermissions()) {
      setState(() => _error = 'Bluetooth/location permission denied.');
      return;
    }

    setState(() => _scanning = true);
    _printer.scanForPrinters().listen(
      (results) {
        if (mounted) setState(() => _results = results);
      },
      onDone: () {
        if (mounted) setState(() => _scanning = false);
      },
      onError: (e) {
        if (mounted) {
          setState(() {
            _error = 'Scan failed: $e';
            _scanning = false;
          });
        }
      },
    );
  }

  Future<void> _connect(ScanResult result) async {
    await _printer.stopScan();
    setState(() => _connecting = true);
    try {
      await _printer.connect(result.device);
      final candidates = _printer.writableCharacteristics;
      setState(() {
        _connectedName = result.device.platformName.isNotEmpty
            ? result.device.platformName
            : result.device.remoteId.str;
        _error = candidates.isEmpty
            ? 'Connected, but no writable characteristic was found — '
                'this device may not be a standard BLE printer, or uses an '
                'encrypted/unsupported write mode.'
            : null;
      });
    } catch (e) {
      setState(() => _error = 'Connect failed: $e');
    } finally {
      if (mounted) setState(() => _connecting = false);
    }
  }

  Future<void> _testPrint() async {
    setState(() {
      _printing = true;
      _error = null;
    });
    try {
      await _printer.printText(
        'Calc2Pay test print\n'
        '--------------------------------\n'
        'If you can read this, your BLE\n'
        'thermal printer is connected.\n',
      );
    } catch (e) {
      setState(() => _error = 'Print failed: $e');
    } finally {
      if (mounted) setState(() => _printing = false);
    }
  }

  Future<void> _disconnect() async {
    await _printer.disconnect();
    setState(() => _connectedName = null);
  }

  @override
  Widget build(BuildContext context) {
    final connected = _printer.isConnected;

    return Scaffold(
      appBar: AppBar(title: const Text('Bluetooth thermal printer')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'This connects a Bluetooth (BLE) thermal printer directly to '
              'your phone — separate from the Calc2Pay device. Use this if '
              'your printer is a standalone BLE receipt printer rather than '
              'the one wired into the Calc2Pay hardware.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          if (connected)
            Card(
              margin: const EdgeInsets.all(12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Connected to: ${_connectedName ?? 'printer'}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        FilledButton.icon(
                          onPressed: _printing ? null : _testPrint,
                          icon: const Icon(Icons.print),
                          label: Text(_printing ? 'Printing...' : 'Test print'),
                        ),
                        OutlinedButton.icon(
                          onPressed: _disconnect,
                          icon: const Icon(Icons.bluetooth_disabled),
                          label: const Text('Disconnect'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: connected
                ? const Center(
                    child: Text('Printer connected. Scan again to switch devices.'),
                  )
                : _results.isEmpty
                    ? Center(
                        child: (_scanning || _connecting)
                            ? const CircularProgressIndicator()
                            : const Text('No devices found yet. Tap scan below.'),
                      )
                    : ListView.builder(
                        itemCount: _results.length,
                        itemBuilder: (context, i) {
                          final r = _results[i];
                          final name = r.device.platformName.isNotEmpty
                              ? r.device.platformName
                              : 'Unknown device';
                          return ListTile(
                            leading: const Icon(Icons.print_outlined),
                            title: Text(name),
                            subtitle: Text(r.device.remoteId.str),
                            trailing: Text('${r.rssi} dBm'),
                            onTap: () => _connect(r),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: connected
          ? null
          : FloatingActionButton.extended(
              onPressed: _scanning ? null : _startScan,
              icon: const Icon(Icons.bluetooth_searching),
              label: Text(_scanning ? 'Scanning...' : 'Scan'),
            ),
    );
  }
}

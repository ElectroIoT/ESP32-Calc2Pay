import 'package:flutter/material.dart';

import '../ble/calc2pay_ble_service.dart';
import '../models/device_status.dart';
import 'ble_printer_screen.dart';
import 'merchant_config_screen.dart';
import 'scan_screen.dart';

/// Read-only device status view + entry point to merchant config.
/// Rev-1 scope only: connection state and firmware version — no battery
/// state (no battery in Rev-1 hardware), no transaction history (no
/// verified-payment channel yet). See ../../hardware/01-DESIGN-REVIEW.md §17.
class DeviceHomeScreen extends StatefulWidget {
  const DeviceHomeScreen({super.key});

  @override
  State<DeviceHomeScreen> createState() => _DeviceHomeScreenState();
}

class _DeviceHomeScreenState extends State<DeviceHomeScreen> {
  final _ble = Calc2PayBleService.instance;
  DeviceStatus _status = DeviceStatus.unknown();
  String _deviceId = '...';
  String? _error;

  @override
  void initState() {
    super.initState();
    _ble.statusStream.listen((status) {
      if (mounted) setState(() => _status = status);
    });
    _ble.readStatus().then((status) {
      if (mounted) setState(() => _status = status);
    }).catchError((e) {
      if (mounted) setState(() => _error = 'Could not read status: $e');
    });
    _ble.readDeviceId().then((id) {
      if (mounted) setState(() => _deviceId = id);
    }).catchError((e) {
      if (mounted) setState(() => _error = 'Could not read device ID: $e');
    });
  }

  Future<void> _disconnect() async {
    await _ble.disconnect();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ScanScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calc2Pay'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bluetooth_disabled),
            tooltip: 'Disconnect',
            onPressed: _disconnect,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Device status',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _statusRow('Connection', 'Connected'),
                  _statusRow('Firmware version', _status.firmwareVersion),
                  _statusRow('Device state', _status.state),
                  _statusRow('Device ID', _deviceId),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.storefront_outlined),
            title: const Text('Merchant settings'),
            subtitle: const Text('UPI VPA, business name, GST %, discount %'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const MerchantConfigScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.print_outlined),
            title: const Text('Bluetooth thermal printer'),
            subtitle: const Text(
                'Connect a standalone BLE receipt printer (separate from the Calc2Pay device)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const BlePrinterScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _statusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value),
        ],
      ),
    );
  }
}

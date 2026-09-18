import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../ble/ble_permissions.dart';
import '../ble/calc2pay_ble_service.dart';
import 'device_home_screen.dart';

/// Rev-1 entry screen: request BLE permissions, scan for devices advertising
/// the Calc2Pay service UUID, and connect. See ../../README.md's Rev-1 scope
/// — no accounts, no cloud, this is the whole "onboarding" flow.
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final _ble = Calc2PayBleService.instance;
  List<ScanResult> _results = [];
  bool _scanning = false;
  String? _error;

  @override
  void dispose() {
    _ble.stopScan();
    super.dispose();
  }

  Future<void> _startScan() async {
    setState(() {
      _error = null;
      _results = [];
    });

    final granted = await requestBlePermissions();
    if (!granted) {
      setState(() => _error = 'Bluetooth/location permission denied.');
      return;
    }

    setState(() => _scanning = true);
    _ble.scanForDevices().listen(
      (results) {
        if (!mounted) return;
        setState(() => _results = results);
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
    await _ble.stopScan();
    try {
      await _ble.connect(result.device);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DeviceHomeScreen()),
      );
    } catch (e) {
      if (mounted) setState(() => _error = 'Connect failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find your Calc2Pay device')),
      body: Column(
        children: [
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          Expanded(
            child: _results.isEmpty
                ? Center(
                    child: _scanning
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
                        leading: const Icon(Icons.calculate_outlined),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _scanning ? null : _startScan,
        icon: const Icon(Icons.bluetooth_searching),
        label: Text(_scanning ? 'Scanning...' : 'Scan'),
      ),
    );
  }
}

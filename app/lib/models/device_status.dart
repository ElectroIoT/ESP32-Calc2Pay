import 'dart:convert';

/// Mirrors the firmware's status characteristic JSON shape
/// (../../firmware/src/BleService.cpp `notifyStatus`).
class DeviceStatus {
  DeviceStatus({required this.firmwareVersion, required this.state});

  factory DeviceStatus.unknown() =>
      DeviceStatus(firmwareVersion: '?', state: 'unknown');

  factory DeviceStatus.fromJsonString(String source) {
    final json = jsonDecode(source) as Map<String, dynamic>;
    return DeviceStatus(
      firmwareVersion: json['fw_version'] as String? ?? '?',
      state: json['state'] as String? ?? 'unknown',
    );
  }

  final String firmwareVersion;
  final String state;
}

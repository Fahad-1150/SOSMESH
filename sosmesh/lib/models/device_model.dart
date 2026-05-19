import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DeviceModel {
  final String id;
  final String name;
  final String address;
  final String connectionType; // 'bluetooth' or 'wifi'
  final DateTime discoveredTime;
  final int? rssi;
  final ScanResult? scanResult; // For Bluetooth

  DeviceModel({
    required this.id,
    required this.name,
    required this.address,
    required this.connectionType,
    required this.discoveredTime,
    this.rssi,
    this.scanResult,
  });

  factory DeviceModel.fromScanResult(ScanResult result) {
    return DeviceModel(
      id: result.device.remoteId.str,
      name: result.device.name.isNotEmpty
          ? result.device.name
          : 'Unknown Device',
      address: result.device.remoteId.str,
      connectionType: 'bluetooth',
      discoveredTime: DateTime.now(),
      rssi: result.rssi,
      scanResult: result,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          address == other.address;

  @override
  int get hashCode => id.hashCode ^ address.hashCode;
}

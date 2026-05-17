import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

class BLEService {
  static final BLEService _instance = BLEService._internal();

  factory BLEService() {
    return _instance;
  }

  BLEService._internal();

  List<ScanResult> _discoveredDevices = [];

  List<ScanResult> get discoveredDevices => _discoveredDevices;

  Future<bool> requestPermissions() async {
    final status = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    return status.values.every((p) => p.isGranted);
  }

  Future<void> startScan() async {
    try {
      _discoveredDevices.clear();

      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));

      FlutterBluePlus.scanResults.listen((results) {
        _discoveredDevices = results;
      });
    } catch (e) {
      debugPrint('Error starting scan: $e');
    }
  }

  Future<void> stopScan() async {
    try {
      await FlutterBluePlus.stopScan();
    } catch (e) {
      debugPrint('Error stopping scan: $e');
    }
  }

  bool get isScanning => FlutterBluePlus.isScanningNow;

  Future<bool> isBluetoothEnabled() async {
    try {
      return await FlutterBluePlus.adapterState.first.then(
        (state) => state == BluetoothAdapterState.on,
      );
    } catch (e) {
      debugPrint('Error checking Bluetooth state: $e');
      return false;
    }
  }

  Stream<BluetoothAdapterState> getBluetoothStateStream() {
    return FlutterBluePlus.adapterState;
  }
}

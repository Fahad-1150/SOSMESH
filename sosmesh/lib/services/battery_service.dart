import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/foundation.dart';

class BatteryService {
  static final BatteryService _instance = BatteryService._internal();

  factory BatteryService() {
    return _instance;
  }

  BatteryService._internal();

  final Battery _battery = Battery();
  int _batteryLevel = 100;
  BatteryState _batteryState = BatteryState.full;

  int get batteryLevel => _batteryLevel;
  BatteryState get batteryState => _batteryState;

  Future<void> initializeBattery() async {
    try {
      _batteryLevel = await _battery.batteryLevel;
      _batteryState = await _battery.batteryState;
    } catch (e) {
      debugPrint('Error initializing battery: $e');
      _batteryLevel = 100;
    }
  }

  Future<void> updateBatteryStatus() async {
    try {
      _batteryLevel = await _battery.batteryLevel;
      _batteryState = await _battery.batteryState;
    } catch (e) {
      debugPrint('Error updating battery: $e');
    }
  }

  Stream<BatteryState> get onBatteryStateChanged =>
      _battery.onBatteryStateChanged;

  String getBatteryStateText() {
    switch (_batteryState) {
      case BatteryState.full:
        return 'Full';
      case BatteryState.charging:
        return 'Charging';
      case BatteryState.discharging:
        return 'Discharging';
      case BatteryState.connectedNotCharging:
        return 'Connected';
      case BatteryState.unknown:
        return 'Unknown';
    }
  }
}

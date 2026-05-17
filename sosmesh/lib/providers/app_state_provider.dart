import 'dart:async';
import 'package:flutter/material.dart';
import '../services/ble_service.dart';
import '../services/location_service.dart';
import '../services/sos_service.dart';
import '../services/battery_service.dart';
import '../services/flashlight_service.dart';
import '../services/connectivity_service.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class AppStateProvider extends ChangeNotifier {
  final BLEService _bleService = BLEService();
  final LocationService _locationService = LocationService();
  final SOSService _sosService = SOSService();
  final BatteryService _batteryService = BatteryService();
  final FlashlightService _flashlightService = FlashlightService();
  final ConnectivityService _connectivityService = ConnectivityService();

  List<ScanResult> _nearbyDevices = [];
  List<SOSMessage> _receivedSOS = [];
  bool _isBluetoothOn = false;
  bool _isWiFiOn = false;
  int _batteryLevel = 100;
  bool _flashEnabled = false;
  bool _isSOS = false;
  Timer? _batteryUpdateTimer;
  StreamSubscription? _bluetoothSubscription;
  StreamSubscription? _wifiSubscription;

  // Getters
  List<ScanResult> get nearbyDevices => _nearbyDevices;
  List<SOSMessage> get receivedSOS => _receivedSOS;
  bool get isBluetoothOn => _isBluetoothOn;
  bool get isWiFiOn => _isWiFiOn;
  int get batteryLevel => _batteryLevel;
  bool get flashEnabled => _flashEnabled;
  bool get isSOS => _isSOS;
  BLEService get bleService => _bleService;
  SOSService get sosService => _sosService;

  // For backward compatibility
  bool get isLocationOn => _isWiFiOn;

  AppStateProvider() {
    _initializeServices();
    _startBatteryMonitoring();
  }

  Future<void> _initializeServices() async {
    try {
      await _bleService.requestPermissions();

      // Initialize Bluetooth status
      _isBluetoothOn = await _bleService.isBluetoothEnabled();
      _bluetoothSubscription = _bleService.getBluetoothStateStream().listen((
        state,
      ) {
        _isBluetoothOn = state == BluetoothAdapterState.on;
        notifyListeners();
      });

      // Initialize WiFi status
      await _connectivityService.initialize();
      _isWiFiOn = _connectivityService.isWiFiConnected;
      _connectivityService.startListening((isConnected) {
        _isWiFiOn = isConnected;
        notifyListeners();
      });

      // Initialize battery service
      await _batteryService.initializeBattery();
      _batteryLevel = _batteryService.batteryLevel;

      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing services: $e');
      _isBluetoothOn = false;
      _isWiFiOn = false;
    }
  }

  void _startBatteryMonitoring() {
    // Update battery level every 5 seconds
    _batteryUpdateTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      await _batteryService.updateBatteryStatus();
      if (_batteryLevel != _batteryService.batteryLevel) {
        _batteryLevel = _batteryService.batteryLevel;
        notifyListeners();
      }
    });
  }

  Future<void> startBluetoothScan() async {
    if (_isBluetoothOn) {
      await _bleService.startScan();
      _updateNearbyDevices();
    }
  }

  void _updateNearbyDevices() {
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      _nearbyDevices = _bleService.discoveredDevices;
      notifyListeners();

      if (!_bleService.isScanning) {
        timer.cancel();
      }
    });
  }

  Future<void> stopBluetoothScan() async {
    await _bleService.stopScan();
  }

  Future<void> broadcastSOS(String message, String emergency) async {
    _isSOS = true;
    notifyListeners();

    await _sosService.broadcastSOS(
      senderName: 'User',
      message: message,
      emergency: emergency,
    );
  }

  void receiveSOS(SOSMessage message) {
    _sosService.receiveSOSMessage(message);
    _receivedSOS = _sosService.receivedMessages;
    notifyListeners();
  }

  void toggleFlash() async {
    _flashEnabled = !_flashEnabled;

    if (_flashEnabled) {
      await _flashlightService.turnOnFlashlight();
    } else {
      await _flashlightService.turnOffFlashlight();
    }

    notifyListeners();
  }

  Future<String> getCurrentLocation() async {
    final position = await _locationService.getCurrentLocation();
    if (position != null) {
      return await _locationService.getLocationAddress(position);
    }
    return 'Location unavailable';
  }

  @override
  void dispose() {
    _batteryUpdateTimer?.cancel();
    _bluetoothSubscription?.cancel();
    _wifiSubscription?.cancel();
    // Make sure flashlight is turned off when app closes
    _flashlightService.turnOffFlashlight();
    super.dispose();
  }

  void setSOS(bool value) {
    _isSOS = value;
    notifyListeners();
  }
}

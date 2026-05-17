import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();

  factory ConnectivityService() {
    return _instance;
  }

  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  bool _isWiFiConnected = false;

  bool get isWiFiConnected => _isWiFiConnected;

  Future<void> initialize() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateWiFiStatus(result);
    } catch (e) {
      debugPrint('Error initializing connectivity: $e');
      _isWiFiConnected = false;
    }
  }

  void startListening(Function(bool) onWiFiStatusChanged) {
    _connectivity.onConnectivityChanged.listen((result) {
      _updateWiFiStatus(result);
      onWiFiStatusChanged(_isWiFiConnected);
    });
  }

  void _updateWiFiStatus(List<ConnectivityResult> result) {
    _isWiFiConnected = result.contains(ConnectivityResult.wifi);
    debugPrint('WiFi connected: $_isWiFiConnected');
  }
}

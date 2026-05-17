import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService {
  static final ConnectivityService _instance =
      ConnectivityService._internal();

  factory ConnectivityService() => _instance;

  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();

  bool _isWiFiConnected = false;
  bool _hasInternet = false;

  bool get isWiFiConnected => _isWiFiConnected;
  bool get hasInternet => _hasInternet;

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  // 🔹 Initialize connectivity status
  Future<void> initialize() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);
      await _checkInternetAccess();
    } catch (e) {
      debugPrint('Error initializing connectivity: $e');
      _isWiFiConnected = false;
      _hasInternet = false;
    }
  }

  // 🔹 Start listening for changes
  void startListening(Function(bool isWiFi, bool hasInternet) onChanged) {
    _subscription = _connectivity.onConnectivityChanged.listen((results) async {
      _updateConnectionStatus(results);
      await _checkInternetAccess();
      onChanged(_isWiFiConnected, _hasInternet);
    });
  }

  // 🔹 Stop listening
  void stopListening() {
    _subscription?.cancel();
  }

  // 🔹 Update WiFi status
  void _updateConnectionStatus(List<ConnectivityResult> results) {
    _isWiFiConnected = results.contains(ConnectivityResult.wifi);
    debugPrint('WiFi connected: $_isWiFiConnected');
  }

  // 🔹 Internet check
  Future<void> _checkInternetAccess() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      _hasInternet = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      _hasInternet = false;
    }

    debugPrint('Internet available: $_hasInternet');
  }

  // 🔹 OPEN WIFI SETTINGS (now inside class)
  Future<void> openWifiSettings() async {
    if (Platform.isAndroid) {
      await Process.run('am', [
        'start',
        '-a',
        'android.settings.WIFI_SETTINGS'
      ]);
    } else {
      debugPrint('WiFi settings not supported on this platform');
    }
  }
}
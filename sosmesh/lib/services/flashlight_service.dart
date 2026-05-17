import 'package:flutter/foundation.dart';
import 'package:torch_light/torch_light.dart';
import 'package:permission_handler/permission_handler.dart';

class FlashlightService {
  static final FlashlightService _instance = FlashlightService._internal();

  factory FlashlightService() => _instance;

  FlashlightService._internal();

  bool _isFlashOn = false;
  bool get isFlashOn => _isFlashOn;

  /// Request camera permission
  Future<void> _requestPermission() async {
    var status = await Permission.camera.request();
    if (!status.isGranted) {
      throw Exception("Camera permission denied");
    }
  }

  Future<void> turnOnFlashlight() async {
    try {
      await _requestPermission();

      await TorchLight.enableTorch();
      _isFlashOn = true;

      debugPrint('Flashlight: ON');
    } catch (e, s) {
      debugPrint('Torch error (ON): $e');
      debugPrint('$s');
    }
  }

  Future<void> turnOffFlashlight() async {
    try {
      await TorchLight.disableTorch();
      _isFlashOn = false;

      debugPrint('Flashlight: OFF');
    } catch (e, s) {
      debugPrint('Torch error (OFF): $e');
      debugPrint('$s');
    }
  }

  Future<void> toggleFlashlight() async {
    if (_isFlashOn) {
      await turnOffFlashlight();
    } else {
      await turnOnFlashlight();
    }
  }
}

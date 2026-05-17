import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';

class FlashlightService {
  static final FlashlightService _instance = FlashlightService._internal();

  factory FlashlightService() => _instance;

  FlashlightService._internal();

  bool _isFlashOn = false;
  bool get isFlashOn => _isFlashOn;

  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;

  bool _isBlinking = false;

  /// Initialize camera
  Future<void> _initializeCamera() async {
    if (_isCameraInitialized) return;

    try {
      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras!.first,
          ResolutionPreset.low,
          enableAudio: false,
        );

        await _cameraController!.initialize();
        _isCameraInitialized = true;

        debugPrint('Camera initialized for flashlight control');
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  Future<bool> _requestPermission() async {
    var status = await Permission.camera.request();
    return status.isGranted;
  }

  /// 🔴 START BLINKING (CONTINUOUS)
  Future<void> startBlinking({int delayMs = 300}) async {
    if (_isBlinking) return;
    _isBlinking = true;

    bool permissionGranted = await _requestPermission();
    if (!permissionGranted) return;

    await _initializeCamera();

    if (_cameraController == null) return;

    while (_isBlinking) {
      try {
        await _cameraController!.setFlashMode(FlashMode.torch);
        _isFlashOn = true;

        await Future.delayed(Duration(milliseconds: delayMs));

        await _cameraController!.setFlashMode(FlashMode.off);
        _isFlashOn = false;

        await Future.delayed(Duration(milliseconds: delayMs));
      } catch (e) {
        debugPrint('Blink error: $e');
        break;
      }
    }
  }

  /// 🔴 STOP BLINKING
  Future<void> stopBlinking() async {
    _isBlinking = false;

    try {
      if (_cameraController != null) {
        await _cameraController!.setFlashMode(FlashMode.off);
      }
      _isFlashOn = false;
    } catch (e) {
      debugPrint('Stop blink error: $e');
    }
  }

  Future<void> turnOnFlashlight() async {
    bool permissionGranted = await _requestPermission();
    if (!permissionGranted) return;

    await _initializeCamera();

    if (_cameraController != null) {
      await _cameraController!.setFlashMode(FlashMode.torch);
      _isFlashOn = true;
    }
  }

  Future<void> turnOffFlashlight() async {
    if (_cameraController != null) {
      await _cameraController!.setFlashMode(FlashMode.off);
    }
    _isFlashOn = false;
  }

  Future<void> toggleFlashlight() async {
    if (_isFlashOn) {
      await turnOffFlashlight();
    } else {
      await turnOnFlashlight();
    }
  }

  Future<void> dispose() async {
    _isBlinking = false;

    try {
      await _cameraController?.dispose();
      _cameraController = null;
      _isCameraInitialized = false;
    } catch (e) {
      debugPrint('Dispose error: $e');
    }
  }
}

final flashlightService = FlashlightService();

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

  /// Request camera permission for flashlight
  Future<bool> _requestPermission() async {
    var status = await Permission.camera.request();
    if (!status.isGranted) {
      debugPrint("Camera permission denied");
      return false;
    }
    return true;
  }

  Future<void> turnOnFlashlight() async {
    try {
      bool permissionGranted = await _requestPermission();
      if (!permissionGranted) {
        debugPrint('Flashlight: Permission denied');
        return;
      }

      await _initializeCamera();

      if (_isCameraInitialized && _cameraController != null) {
        await _cameraController!.setFlashMode(FlashMode.torch);
        _isFlashOn = true;
        debugPrint('Flashlight: ON');
      }
    } catch (e, s) {
      debugPrint('Flashlight error (ON): $e');
      debugPrint('$s');
    }
  }

  Future<void> turnOffFlashlight() async {
    try {
      if (_isCameraInitialized && _cameraController != null) {
        await _cameraController!.setFlashMode(FlashMode.off);
      }
      _isFlashOn = false;
      debugPrint('Flashlight: OFF');
    } catch (e, s) {
      debugPrint('Flashlight error (OFF): $e');
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

  /// Cleanup resources
  Future<void> dispose() async {
    try {
      if (_cameraController != null) {
        await _cameraController!.dispose();
        _cameraController = null;
        _isCameraInitialized = false;
        debugPrint('Flashlight service disposed');
      }
    } catch (e) {
      debugPrint('Error disposing flashlight service: $e');
    }
  }
}

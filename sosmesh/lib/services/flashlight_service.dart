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

  /// Request camera permission
  Future<bool> _requestPermission() async {
    var status = await Permission.camera.request();
    if (!status.isGranted) {
      debugPrint("Camera permission denied");
      return false;
    }
    return true;
  }

  /// 🔴 FIXED: Blink flashlight (NOW OUTSIDE initializeCamera)
  Future<void> blinkFlashlight({int times = 5}) async {
    try {
      bool permissionGranted = await _requestPermission();
      if (!permissionGranted) return;

      await _initializeCamera();

      if (_cameraController == null || !_isCameraInitialized) return;

      for (int i = 0; i < times; i++) {
        // ON
        await _cameraController!.setFlashMode(FlashMode.torch);
        _isFlashOn = true;
        debugPrint('ON');

        await Future.delayed(const Duration(milliseconds: 350));

        // OFF
        await _cameraController!.setFlashMode(FlashMode.off);
        _isFlashOn = false;
        debugPrint('OFF');

        await Future.delayed(const Duration(milliseconds: 350));
      }
    } catch (e, s) {
      debugPrint('Blink error: $e');
      debugPrint('$s');
    }
  }

  Future<void> turnOnFlashlight() async {
    try {
      bool permissionGranted = await _requestPermission();
      if (!permissionGranted) return;

      await _initializeCamera();

      if (_cameraController != null && _isCameraInitialized) {
        await _cameraController!.setFlashMode(FlashMode.torch);
        _isFlashOn = true;
      }
    } catch (e, s) {
      debugPrint('Flash ON error: $e');
      debugPrint('$s');
    }
  }

  Future<void> turnOffFlashlight() async {
    try {
      if (_cameraController != null && _isCameraInitialized) {
        await _cameraController!.setFlashMode(FlashMode.off);
      }
      _isFlashOn = false;
    } catch (e, s) {
      debugPrint('Flash OFF error: $e');
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

  Future<void> dispose() async {
    try {
      await _cameraController?.dispose();
      _cameraController = null;
      _isCameraInitialized = false;
    } catch (e) {
      debugPrint('Dispose error: $e');
    }
  }
}

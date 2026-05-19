import 'package:flutter/foundation.dart';
import '../models/device_model.dart';
import '../models/pairing_model.dart';
import 'chat_service.dart';

class PairingService {
  static final PairingService _instance = PairingService._internal();
  final ChatService _chatService = ChatService();

  factory PairingService() {
    return _instance;
  }

  PairingService._internal();

  // Initiate pairing with a device
  Future<bool> initiatepairing(
    DeviceModel device,
    String connectionType,
  ) async {
    try {
      debugPrint('Initiating pairing with: ${device.name} via $connectionType');

      // Save the pairing
      final pairing = await _chatService.pairWithDevice(
        device: device,
        connectionType: connectionType,
      );

      debugPrint('Pairing successful: ${pairing.id}');
      return true;
    } catch (e) {
      debugPrint('Error initiating pairing: $e');
      return false;
    }
  }

  // Get all active pairings
  Future<List<PairingModel>> getActivePairings() async {
    try {
      return await _chatService.getAllPairings();
    } catch (e) {
      debugPrint('Error getting active pairings: $e');
      return [];
    }
  }

  // Check if device is paired
  Future<bool> isDevicePaired(String deviceId) async {
    try {
      return await _chatService.isPairedWithDevice(deviceId);
    } catch (e) {
      debugPrint('Error checking if device is paired: $e');
      return false;
    }
  }

  // Get pairing info for a device
  Future<PairingModel?> getPairingInfo(String deviceId) async {
    try {
      return await _chatService.getPairingForDevice(deviceId);
    } catch (e) {
      debugPrint('Error getting pairing info: $e');
      return null;
    }
  }

  // Validate pairing (check if both devices are still available)
  Future<bool> validatePairing(PairingModel pairing) async {
    try {
      // In a real implementation, you would check if the devices are still discoverable
      // For now, we just return true if the pairing exists
      return true;
    } catch (e) {
      debugPrint('Error validating pairing: $e');
      return false;
    }
  }
}

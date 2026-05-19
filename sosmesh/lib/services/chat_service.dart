import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/message_model.dart';
import '../models/device_model.dart';
import '../models/pairing_model.dart';
import 'chat_database_service.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  final ChatDatabaseService _dbService = ChatDatabaseService();

  late String _localDeviceId;
  late String _localDeviceName;

  factory ChatService() {
    return _instance;
  }

  ChatService._internal();

  Future<void> initialize(String deviceId, String deviceName) async {
    _localDeviceId = deviceId;
    _localDeviceName = deviceName;
    debugPrint(
      'ChatService initialized with device: $_localDeviceName ($_localDeviceId)',
    );
  }

  String get localDeviceId => _localDeviceId;
  String get localDeviceName => _localDeviceName;

  // Send a message
  Future<MessageModel> sendMessage({
    required String receiverId,
    required String receiverName,
    required String content,
  }) async {
    try {
      final message = MessageModel(
        id: const Uuid().v4(),
        senderId: _localDeviceId,
        senderName: _localDeviceName,
        receiverId: receiverId,
        content: content,
        timestamp: DateTime.now(),
        status: 'sent',
        messageType: 'text',
      );

      await _dbService.insertMessage(message);
      debugPrint('Message sent to $receiverName: $content');

      return message;
    } catch (e) {
      debugPrint('Error sending message: $e');
      rethrow;
    }
  }

  // Receive a message
  Future<void> receiveMessage({
    required String senderId,
    required String senderName,
    required String content,
  }) async {
    try {
      final message = MessageModel(
        id: const Uuid().v4(),
        senderId: senderId,
        senderName: senderName,
        receiverId: _localDeviceId,
        content: content,
        timestamp: DateTime.now(),
        status: 'delivered',
        messageType: 'text',
      );

      await _dbService.insertMessage(message);
      debugPrint('Message received from $senderName: $content');
    } catch (e) {
      debugPrint('Error receiving message: $e');
      rethrow;
    }
  }

  // Get conversation with a device
  Future<List<MessageModel>> getConversation(String deviceId) async {
    try {
      final messages = await _dbService.getConversation(deviceId);
      return messages;
    } catch (e) {
      debugPrint('Error getting conversation: $e');
      return [];
    }
  }

  // Get all unique chat partners
  Future<List<String>> getChatPartners() async {
    try {
      final partners = await _dbService.getAllChatPartners();
      return partners;
    } catch (e) {
      debugPrint('Error getting chat partners: $e');
      return [];
    }
  }

  // Mark message as read
  Future<void> markMessageAsRead(String messageId) async {
    try {
      await _dbService.updateMessageStatus(messageId, 'read');
    } catch (e) {
      debugPrint('Error marking message as read: $e');
    }
  }

  // Delete a message
  Future<void> deleteMessage(String messageId) async {
    try {
      await _dbService.deleteMessage(messageId);
    } catch (e) {
      debugPrint('Error deleting message: $e');
    }
  }

  // Search messages
  Future<List<MessageModel>> searchMessages(String query) async {
    try {
      return await _dbService.searchMessages(query);
    } catch (e) {
      debugPrint('Error searching messages: $e');
      return [];
    }
  }

  // Pair with a device
  Future<PairingModel> pairWithDevice({
    required DeviceModel device,
    required String connectionType,
  }) async {
    try {
      final pairing = PairingModel(
        id: const Uuid().v4(),
        device1Id: _localDeviceId,
        device1Name: _localDeviceName,
        device2Id: device.id,
        device2Name: device.name,
        pairingTime: DateTime.now(),
        isActive: true,
        connectionType: connectionType,
      );

      await _dbService.insertPairing(pairing);
      debugPrint('Paired with device: ${device.name}');

      return pairing;
    } catch (e) {
      debugPrint('Error pairing with device: $e');
      rethrow;
    }
  }

  // Get all pairings
  Future<List<PairingModel>> getAllPairings() async {
    try {
      return await _dbService.getAllPairings();
    } catch (e) {
      debugPrint('Error getting pairings: $e');
      return [];
    }
  }

  // Get pairing for a specific device
  Future<PairingModel?> getPairingForDevice(String deviceId) async {
    try {
      return await _dbService.getPairingForDevice(deviceId);
    } catch (e) {
      debugPrint('Error getting pairing for device: $e');
      return null;
    }
  }

  // Check if paired with device
  Future<bool> isPairedWithDevice(String deviceId) async {
    try {
      final pairing = await getPairingForDevice(deviceId);
      return pairing != null;
    } catch (e) {
      debugPrint('Error checking pairing status: $e');
      return false;
    }
  }

  // Save discovered device
  Future<void> saveDiscoveredDevice(DeviceModel device) async {
    try {
      await _dbService.insertDevice(device);
    } catch (e) {
      debugPrint('Error saving discovered device: $e');
    }
  }

  // Get all discovered devices
  Future<List<DeviceModel>> getAllDiscoveredDevices() async {
    try {
      return await _dbService.getAllDiscoveredDevices();
    } catch (e) {
      debugPrint('Error getting discovered devices: $e');
      return [];
    }
  }
}

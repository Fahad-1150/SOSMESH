import 'package:uuid/uuid.dart';
import 'package:geolocator/geolocator.dart';

class SOSMessage {
  final String id;
  final String senderName;
  final String message;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String emergency;

  SOSMessage({
    String? id,
    required this.senderName,
    required this.message,
    required this.latitude,
    required this.longitude,
    required this.emergency,
    DateTime? timestamp,
  }) : id = id ?? const Uuid().v4(),
       timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderName': senderName,
      'message': message,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
      'emergency': emergency,
    };
  }

  factory SOSMessage.fromJson(Map<String, dynamic> json) {
    return SOSMessage(
      id: json['id'],
      senderName: json['senderName'],
      message: json['message'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      emergency: json['emergency'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class SOSService {
  static final SOSService _instance = SOSService._internal();

  factory SOSService() {
    return _instance;
  }

  SOSService._internal();

  final List<SOSMessage> _receivedMessages = [];
  final List<SOSMessage> _sentMessages = [];

  List<SOSMessage> get receivedMessages => _receivedMessages;
  List<SOSMessage> get sentMessages => _sentMessages;

  Future<SOSMessage> broadcastSOS({
    required String senderName,
    required String message,
    required String emergency,
  }) async {
    try {
      final position = await Geolocator.getCurrentPosition();

      final sosMsg = SOSMessage(
        senderName: senderName,
        message: message,
        latitude: position.latitude,
        longitude: position.longitude,
        emergency: emergency,
      );

      _sentMessages.add(sosMsg);
      return sosMsg;
    } catch (e) {
      // Fallback if location is not available
      final sosMsg = SOSMessage(
        senderName: senderName,
        message: message,
        latitude: 0.0,
        longitude: 0.0,
        emergency: emergency,
      );

      _sentMessages.add(sosMsg);
      return sosMsg;
    }
  }

  void receiveSOSMessage(SOSMessage message) {
    _receivedMessages.add(message);
  }

  List<SOSMessage> getSOSByType(String type) {
    return _receivedMessages.where((msg) => msg.emergency == type).toList();
  }

  void clearMessages() {
    _receivedMessages.clear();
    _sentMessages.clear();
  }
}

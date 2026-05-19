import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/message_model.dart';
import '../models/pairing_model.dart';
import '../models/device_model.dart';

class ChatDatabaseService {
  static final ChatDatabaseService _instance = ChatDatabaseService._internal();
  late Database _database;
  bool _isInitialized = false;

  factory ChatDatabaseService() {
    return _instance;
  }

  ChatDatabaseService._internal();

  Future<Database> get database async {
    if (!_isInitialized) {
      await _initDatabase();
    }
    return _database;
  }

  Future<void> _initDatabase() async {
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String dbPath = '${appDocDir.path}/sosmesh_chat.db';

      _database = await openDatabase(
        dbPath,
        version: 1,
        onCreate: _createTables,
      );

      _isInitialized = true;
      debugPrint('Chat database initialized at: $dbPath');
    } catch (e) {
      debugPrint('Error initializing chat database: $e');
      rethrow;
    }
  }

  Future<void> _createTables(Database db, int version) async {
    try {
      // Messages table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS messages (
          id TEXT PRIMARY KEY,
          senderId TEXT NOT NULL,
          senderName TEXT NOT NULL,
          receiverId TEXT NOT NULL,
          content TEXT NOT NULL,
          timestamp TEXT NOT NULL,
          status TEXT DEFAULT 'sent',
          messageType TEXT DEFAULT 'text'
        )
      ''');

      // Pairings table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS pairings (
          id TEXT PRIMARY KEY,
          device1Id TEXT NOT NULL,
          device1Name TEXT NOT NULL,
          device2Id TEXT NOT NULL,
          device2Name TEXT NOT NULL,
          pairingTime TEXT NOT NULL,
          isActive INTEGER DEFAULT 1,
          connectionType TEXT NOT NULL
        )
      ''');

      // Devices table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS devices (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          address TEXT NOT NULL,
          connectionType TEXT NOT NULL,
          discoveredTime TEXT NOT NULL,
          rssi INTEGER,
          lastSeen TEXT NOT NULL
        )
      ''');

      // Create indexes for faster queries
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_messages_receiver ON messages(receiverId)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_messages_sender ON messages(senderId)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_messages_timestamp ON messages(timestamp)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_pairings_device1 ON pairings(device1Id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_pairings_device2 ON pairings(device2Id)',
      );

      debugPrint('Chat database tables created successfully');
    } catch (e) {
      debugPrint('Error creating tables: $e');
      rethrow;
    }
  }

  // Message operations
  Future<void> insertMessage(MessageModel message) async {
    try {
      final db = await database;
      await db.insert(
        'messages',
        message.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      debugPrint('Message saved: ${message.id}');
    } catch (e) {
      debugPrint('Error inserting message: $e');
      rethrow;
    }
  }

  Future<List<MessageModel>> getConversation(String deviceId) async {
    try {
      final db = await database;
      final result = await db.rawQuery(
        '''
        SELECT * FROM messages 
        WHERE (senderId = ? OR receiverId = ?)
        ORDER BY timestamp DESC
      ''',
        [deviceId, deviceId],
      );

      return result.map((map) => MessageModel.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error fetching conversation: $e');
      return [];
    }
  }

  Future<List<String>> getAllChatPartners() async {
    try {
      final db = await database;
      final result = await db.rawQuery(
        '''
        SELECT DISTINCT CASE 
          WHEN senderId != ? THEN senderId 
          ELSE receiverId 
        END as partnerId
        FROM messages
        ORDER BY timestamp DESC
      ''',
        ['local_device_id'],
      );

      return List<String>.from(result.map((m) => m['partnerId']));
    } catch (e) {
      debugPrint('Error fetching chat partners: $e');
      return [];
    }
  }

  Future<List<MessageModel>> searchMessages(String query) async {
    try {
      final db = await database;
      final result = await db.rawQuery(
        '''
        SELECT * FROM messages 
        WHERE content LIKE ?
        ORDER BY timestamp DESC
      ''',
        ['%$query%'],
      );

      return result.map((map) => MessageModel.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error searching messages: $e');
      return [];
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      final db = await database;
      await db.delete('messages', where: 'id = ?', whereArgs: [messageId]);
    } catch (e) {
      debugPrint('Error deleting message: $e');
    }
  }

  Future<void> updateMessageStatus(String messageId, String status) async {
    try {
      final db = await database;
      await db.update(
        'messages',
        {'status': status},
        where: 'id = ?',
        whereArgs: [messageId],
      );
    } catch (e) {
      debugPrint('Error updating message status: $e');
    }
  }

  // Pairing operations
  Future<void> insertPairing(PairingModel pairing) async {
    try {
      final db = await database;
      await db.insert(
        'pairings',
        pairing.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      debugPrint('Pairing saved: ${pairing.id}');
    } catch (e) {
      debugPrint('Error inserting pairing: $e');
      rethrow;
    }
  }

  Future<List<PairingModel>> getAllPairings() async {
    try {
      final db = await database;
      final result = await db.query(
        'pairings',
        where: 'isActive = ?',
        whereArgs: [1],
        orderBy: 'pairingTime DESC',
      );

      return result.map((map) => PairingModel.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error fetching pairings: $e');
      return [];
    }
  }

  Future<PairingModel?> getPairingForDevice(String deviceId) async {
    try {
      final db = await database;
      final result = await db.query(
        'pairings',
        where: '(device1Id = ? OR device2Id = ?) AND isActive = ?',
        whereArgs: [deviceId, deviceId, 1],
      );

      if (result.isNotEmpty) {
        return PairingModel.fromMap(result.first);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching pairing for device: $e');
      return null;
    }
  }

  // Device operations
  Future<void> insertDevice(DeviceModel device) async {
    try {
      final db = await database;
      await db.insert('devices', {
        'id': device.id,
        'name': device.name,
        'address': device.address,
        'connectionType': device.connectionType,
        'discoveredTime': device.discoveredTime.toIso8601String(),
        'rssi': device.rssi,
        'lastSeen': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      debugPrint('Error inserting device: $e');
    }
  }

  Future<List<DeviceModel>> getAllDiscoveredDevices() async {
    try {
      final db = await database;
      final result = await db.query('devices', orderBy: 'lastSeen DESC');

      return result
          .map(
            (map) => DeviceModel(
              id: map['id'] as String,
              name: map['name'] as String,
              address: map['address'] as String,
              connectionType: map['connectionType'] as String,
              discoveredTime: DateTime.parse(map['discoveredTime'] as String),
              rssi: map['rssi'] as int?,
            ),
          )
          .toList();
    } catch (e) {
      debugPrint('Error fetching devices: $e');
      return [];
    }
  }

  Future<void> clearOldDevices({int daysOld = 7}) async {
    try {
      final db = await database;
      final cutoffDate = DateTime.now()
          .subtract(Duration(days: daysOld))
          .toIso8601String();

      await db.delete(
        'devices',
        where: 'lastSeen < ?',
        whereArgs: [cutoffDate],
      );

      debugPrint('Old devices cleared');
    } catch (e) {
      debugPrint('Error clearing old devices: $e');
    }
  }

  Future<void> deleteAllData() async {
    try {
      final db = await database;
      await db.delete('messages');
      await db.delete('pairings');
      await db.delete('devices');
      debugPrint('All chat data deleted');
    } catch (e) {
      debugPrint('Error deleting all data: $e');
    }
  }
}

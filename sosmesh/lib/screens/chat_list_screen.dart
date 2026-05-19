import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../models/pairing_model.dart';
import '../services/chat_service.dart';
import 'chat_detail_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ChatService _chatService = ChatService();
  late Future<List<Map<String, dynamic>>> _connectedDevicesFuture;

  @override
  void initState() {
    super.initState();
    _loadConnectedDevices();
  }

  void _loadConnectedDevices() {
    _connectedDevicesFuture = _getConnectedDevices();
  }

  Future<List<Map<String, dynamic>>> _getConnectedDevices() async {
    try {
      // Get all pairings
      final pairings = await _chatService.getAllPairings();
      final devicesList = <Map<String, dynamic>>[];

      for (var pairing in pairings) {
        // Get unread message count
        final messages = await _chatService.getConversation(
          pairing.device2Id == _chatService.localDeviceId
              ? pairing.device1Id
              : pairing.device2Id,
        );

        final unreadCount = messages
            .where(
              (m) =>
                  m.receiverId == _chatService.localDeviceId &&
                  m.status != 'read',
            )
            .length;

        // Determine other device info based on which device is local
        final otherDeviceId = pairing.device1Id == _chatService.localDeviceId
            ? pairing.device2Id
            : pairing.device1Id;
        final otherDeviceName = pairing.device1Id == _chatService.localDeviceId
            ? pairing.device2Name
            : pairing.device1Name;

        devicesList.add({
          'pairing': pairing,
          'deviceId': otherDeviceId,
          'deviceName': otherDeviceName,
          'connectionType': pairing.connectionType,
          'pairingTime': pairing.pairingTime,
          'unreadCount': unreadCount,
        });
      }

      // Sort by pairing time (most recent first)
      devicesList.sort(
        (a, b) => (b['pairingTime'] as DateTime).compareTo(
          a['pairingTime'] as DateTime,
        ),
      );

      return devicesList;
    } catch (e) {
      debugPrint('Error loading connected devices: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
      ),
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _connectedDevicesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading devices: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final devices = snapshot.data ?? [];

          if (devices.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.devices_other, size: 80, color: Colors.grey[600]),
                  const SizedBox(height: 16),
                  Text(
                    'No connected devices',
                    style: TextStyle(color: Colors.grey[400], fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Go to Find Nearby to pair with devices',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _loadConnectedDevices();
              });
            },
            child: ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final item = devices[index];
                final deviceName = item['deviceName'] as String;
                final connectionType = item['connectionType'] as String;
                final pairingTime = item['pairingTime'] as DateTime;
                final unreadCount = item['unreadCount'] as int;
                final deviceId = item['deviceId'] as String;

                return GestureDetector(
                  onTap: () {
                    // Create a temporary device object for navigation
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatDetailScreen(
                          deviceId: deviceId,
                          deviceName: deviceName,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xff16213e),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.cyan.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Center(
                              child: Text(
                                deviceName[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.cyan,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  deviceName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: connectionType == 'bluetooth'
                                            ? Colors.blue.withOpacity(0.3)
                                            : Colors.amber.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            connectionType == 'bluetooth'
                                                ? Icons.bluetooth
                                                : Icons.wifi,
                                            color: connectionType == 'bluetooth'
                                                ? Colors.blue
                                                : Colors.amber,
                                            size: 12,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            connectionType == 'bluetooth'
                                                ? 'Bluetooth'
                                                : 'WiFi',
                                            style: TextStyle(
                                              color:
                                                  connectionType == 'bluetooth'
                                                  ? Colors.blue
                                                  : Colors.amber,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '● Connected',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _formatTime(pairingTime),
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                              if (unreadCount > 0)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '$unreadCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              else
                                Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey[500],
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final msgDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (msgDate == today) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (msgDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}

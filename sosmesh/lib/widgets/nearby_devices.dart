import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../services/chat_service.dart';
import '../models/device_model.dart';
import 'pairing_dialog.dart';
import '../screens/chat_detail_screen.dart';

class NearbyDevices extends StatefulWidget {
  const NearbyDevices({super.key});

  @override
  State<NearbyDevices> createState() => _NearbyDevicesState();
}

class _NearbyDevicesState extends State<NearbyDevices> {
  final ChatService _chatService = ChatService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AppStateProvider>().startBluetoothScan();
      }
    });
  }

  @override
  void dispose() {
    try {
      if (mounted) {
        context.read<AppStateProvider>().stopBluetoothScan();
      }
    } catch (e) {
      debugPrint('Error stopping scan: $e');
    }
    super.dispose();
  }

  void _showDeviceOptions(
    BuildContext context,
    String deviceName,
    String deviceId,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xff16213e),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              deviceName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text(
                'Pair via Bluetooth',
                style: TextStyle(color: Colors.cyan),
              ),
              leading: const Icon(Icons.bluetooth, color: Colors.cyan),
              onTap: () {
                Navigator.pop(context);
                _pairDevice(deviceName, deviceId, 'bluetooth');
              },
            ),
            ListTile(
              title: const Text(
                'Pair via WiFi',
                style: TextStyle(color: Colors.amber),
              ),
              leading: const Icon(Icons.wifi, color: Colors.amber),
              onTap: () {
                Navigator.pop(context);
                _pairDevice(deviceName, deviceId, 'wifi');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _pairDevice(String deviceName, String deviceId, String connectionType) {
    final device = DeviceModel(
      id: deviceId,
      name: deviceName,
      address: deviceId,
      connectionType: connectionType,
      discoveredTime: DateTime.now(),
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PairingDialog(
        device: device,
        connectionType: connectionType,
        onPairingComplete: () async {
          // Save device to chat database
          await _chatService.saveDiscoveredDevice(device);

          // Navigate to chat screen
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ChatDetailScreen(device: device),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _deviceWidget(String name, String rssi, String deviceId) {
    return GestureDetector(
      onTap: () {
        _showDeviceOptions(context, name, deviceId);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xff203554),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.lightGreen,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Signal: $rssi',
                    style: const TextStyle(color: Colors.cyan, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chat, color: Colors.cyan),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, _) {
        final devices = appState.nearbyDevices;

        return Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              const Text(
                "Find Nearby",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              if (devices.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 8),
                      const Text(
                        'Scanning...',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              else
                ...devices.take(3).map((device) {
                  return _deviceWidget(
                    device.device.platformName.isEmpty
                        ? 'Unknown Device'
                        : device.device.platformName,
                    '${device.rssi} dBm',
                    device.device.remoteId.str,
                  );
                }),
              const SizedBox(height: 8),
              Text(
                'Found ${devices.length} devices',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }
}

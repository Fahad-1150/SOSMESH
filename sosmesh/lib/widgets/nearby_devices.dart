import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';

class NearbyDevices extends StatefulWidget {
  const NearbyDevices({super.key});

  @override
  State<NearbyDevices> createState() => _NearbyDevicesState();
}

class _NearbyDevicesState extends State<NearbyDevices> {
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

  Widget _deviceWidget(String name, String rssi) {
    return Container(
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
          const Icon(Icons.send, color: Colors.cyan),
        ],
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

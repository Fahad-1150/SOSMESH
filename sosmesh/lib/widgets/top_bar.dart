import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, _) {
        return Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Icon(
                Icons.wifi,
                size: 40,
                color: appState.isWiFiOn ? Colors.cyan : Colors.grey,
              ),
              Icon(
                Icons.bluetooth,
                size: 40,
                color: appState.isBluetoothOn ? Colors.blue : Colors.grey,
              ),
              const SizedBox(width: 10),
              Text(
                "SOSMESH",
                style: TextStyle(
                  color: appState.isSOS ? Colors.red : Colors.lightGreen,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.battery_full,
                color: appState.batteryLevel > 20
                    ? Colors.lightGreen
                    : Colors.orange,
                size: 40,
              ),
              Text(
                "${appState.batteryLevel}%",
                style: TextStyle(
                  color: appState.batteryLevel > 20
                      ? Colors.lightGreen
                      : Colors.orange,
                  fontSize: 25,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, _) {
        final battery = appState.batteryLevel.clamp(0, 100);

        return Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Icon(
                Icons.wifi,
                size: 35,
                color: appState.isWiFiOn ? Colors.cyan : Colors.grey,
              ),

              const SizedBox(width: 10),

              Icon(
                Icons.bluetooth,
                size: 35,
                color: appState.isBluetoothOn ? Colors.blue : Colors.grey,
              ),

              const SizedBox(width: 12),

              Text(
                "SOSMESH",
                style: TextStyle(
                  color: appState.isSOS
                      ? Colors.red
                      : const Color.fromARGB(255, 255, 255, 255),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Spacer(),

              // 🔋 Horizontal Battery
              Row(
                children: [
                  Container(
                    width: 45,
                    height: 20,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: battery > 20
                            ? const Color.fromARGB(255, 110, 110, 110)
                            : Colors.red,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Stack(
                      children: [
                        // Fill level
                        FractionallySizedBox(
                          widthFactor: battery / 100,
                          child: Container(
                            decoration: BoxDecoration(
                              color: battery > 20
                                  ? const Color.fromARGB(255, 75, 98, 76)
                                  : Colors.red,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 6),

                  Text(
                    "$battery%",
                    style: TextStyle(
                      color: battery > 20 ? Colors.green : Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

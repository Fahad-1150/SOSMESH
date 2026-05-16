import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';

class SOSReceived extends StatelessWidget {
  const SOSReceived({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, _) {
        final receivedSOS = appState.receivedSOS;
        final latestSOS = receivedSOS.isNotEmpty ? receivedSOS.last : null;

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
                "SOS Received",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 20),
              if (latestSOS == null)
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: const Color(0xff203554),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Center(
                    child: Text(
                      "No SOS\nMessages\nReceived",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.lightGreen),
                    ),
                  ),
                )
              else
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: const Color(0xff0d2f63),
                          title: const Text(
                            'SOS Details',
                            style: TextStyle(color: Colors.red),
                          ),
                          content: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'From: ${latestSOS.senderName}',
                                  style: const TextStyle(color: Colors.cyan),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Emergency: ${latestSOS.emergency}',
                                  style: const TextStyle(color: Colors.orange),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Message: ${latestSOS.message}',
                                  style: const TextStyle(
                                    color: Colors.lightGreen,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Location: ${latestSOS.latitude.toStringAsFixed(4)}, ${latestSOS.longitude.toStringAsFixed(4)}',
                                  style: const TextStyle(color: Colors.cyan),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Time: ${latestSOS.timestamp.toString()}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'Close',
                                style: TextStyle(color: Colors.cyan),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: const Color(0xff203554),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.red, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        '🆘\n${latestSOS.emergency}\n${latestSOS.senderName}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                '${receivedSOS.length} message(s)',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }
}

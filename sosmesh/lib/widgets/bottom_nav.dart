import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/app_state_provider.dart';
import '../widgets/ai.dart';
import '../screens/chat_list_screen.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav>
    with SingleTickerProviderStateMixin {
  late AnimationController _flashController;
  Timer? _blinkTimer;

  @override
  void initState() {
    super.initState();
    _flashController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _flashController.dispose();
    super.dispose();
  }

  void _toggleFlash(AppStateProvider appState) {
    _blinkTimer?.cancel();

    if (appState.flashEnabled) {
      appState.toggleFlash();
      _flashController.stop();
    } else {
      _flashController.repeat(reverse: true);
      appState.toggleFlash();

      _blinkTimer = Timer.periodic(const Duration(milliseconds: 150), (_) {
        if (!appState.flashEnabled) {
          _blinkTimer?.cancel();
          _flashController.stop();
        }
      });
    }
  }

  // 🔴 CANCEL CONFIRMATION
  void _showCancelSOSDialog(AppStateProvider appState) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: const Text(
            "Cancel SOS?",
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            "Do you really want to stop emergency alert?",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("No", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                appState.setSOS(false);
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("SOS Cancelled"),
                    backgroundColor: Colors.grey,
                  ),
                );
              },
              child: const Text("Yes", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, _) {
        return Container(
          padding: const EdgeInsets.all(15),
          color: Colors.black,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // FLASH
              GestureDetector(
                onTap: () => _toggleFlash(appState),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: appState.flashEnabled
                        ? Colors.yellow
                        : const Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        appState.flashEnabled
                            ? Icons.flash_on
                            : Icons.flash_off,
                        color: Colors.black,
                        size: 20,
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        "",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // AI
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AIPage()),
                  );
                },
                child: Row(
                  children: [
                    const Text(
                      "",
                      style: TextStyle(
                        color: Color.fromARGB(255, 143, 145, 146),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xff1a1a1a),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.cyan),
                      ),
                      child: const Icon(
                        Icons.smart_toy,
                        color: Color.fromARGB(255, 255, 255, 255),
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),

              // MESSAGES/CHAT
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChatListScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.chat, color: Colors.black, size: 20),
                      SizedBox(width: 5),
                      Text(
                        "Chat",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 🔴 SINGLE SOS BUTTON (PRESS + HOLD)
              GestureDetector(
                onTap: () {
                  if (!appState.isSOS) {
                    appState.setSOS(true);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("SOS Activated"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },

                onLongPress: () {
                  if (appState.isSOS) {
                    _showCancelSOSDialog(appState);
                  }
                },

                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: appState.isSOS ? Colors.red : Colors.grey,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    appState.isSOS ? "SOS ACTIVE" : "SOS",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

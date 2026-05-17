import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/app_state_provider.dart';

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
    // Cancel any existing blink timer
    _blinkTimer?.cancel();

    if (appState.flashEnabled) {
      // If already on, turn it off
      appState.toggleFlash();
      _flashController.stop();
    } else {
      // Turn on and start blinking
      _flashController.repeat(reverse: true);
      appState.toggleFlash();

      // Create a rapid blinking effect by turning flashlight on/off repeatedly
      _blinkTimer = Timer.periodic(const Duration(milliseconds: 150), (_) {
        if (appState.flashEnabled) {
          // The flashlight will be kept on by the provider
          // This timer is mainly for the UI animation
        } else {
          _blinkTimer?.cancel();
          _flashController.stop();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, _) {
        return Container(
          padding: const EdgeInsets.all(15),
          color: const Color(0xff0d2f63),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  _toggleFlash(appState);
                },
                child: ScaleTransition(
                  scale: Tween<double>(begin: 1.0, end: 1.2).animate(
                    CurvedAnimation(
                      parent: _flashController,
                      curve: Curves.easeInOut,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: appState.flashEnabled
                          ? Colors.yellow
                          : Colors.cyan,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: appState.flashEnabled
                          ? [
                              BoxShadow(
                                color: Colors.yellow.withValues(alpha: 0.5),
                                blurRadius: 15,
                                spreadRadius: 3,
                              ),
                            ]
                          : [],
                    ),
                    child: Row(
                      children: [
                        appState.flashEnabled
                            ? const Icon(
                                Icons.flash_on,
                                color: Colors.black,
                                size: 20,
                              )
                            : const Icon(
                                Icons.flash_off,
                                color: Colors.black,
                                size: 20,
                              ),
                        const SizedBox(width: 5),
                        Text(
                          appState.flashEnabled ? "⚡ FLASHING" : "⚡ Flash",
                          style: TextStyle(
                            color: appState.flashEnabled
                                ? Colors.black
                                : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: const Color(0xff0d2f63),
                        title: const Text(
                          'Voice Chat',
                          style: TextStyle(color: Colors.cyan),
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.smart_toy,
                              size: 50,
                              color: Colors.cyan,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'AI Assistant',
                              style: TextStyle(
                                color: Colors.lightGreen,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Ask for help, report your situation, or get navigation assistance.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: const Color(0xff203554),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.cyan,
                                  width: 2,
                                ),
                              ),
                              child: const Text(
                                'Voice input ready\nPress and speak...',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.cyan),
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'Close',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Voice recording started...'),
                                  backgroundColor: Colors.blue,
                                ),
                              );
                            },
                            child: const Text(
                              'Start Recording',
                              style: TextStyle(color: Colors.cyan),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Row(
                  children: [
                    const Text(
                      "Talk with",
                      style: TextStyle(
                        color: Colors.cyan,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xff203554),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.cyan, width: 1),
                      ),
                      child: const Icon(
                        Icons.smart_toy,
                        color: Colors.cyan,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

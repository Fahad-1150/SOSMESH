import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/app_state_provider.dart';
import '../widgets/ai.dart';

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
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ✅ CHANGED PART ONLY
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

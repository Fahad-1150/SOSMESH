import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';

class PushSOSButton extends StatefulWidget {
  const PushSOSButton({super.key});

  @override
  State<PushSOSButton> createState() => _PushSOSButtonState();
}

class _PushSOSButtonState extends State<PushSOSButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showSOSDialog(BuildContext context, AppStateProvider appState) {
    final messageController = TextEditingController();
    String selectedEmergency = 'Medical';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xff0d2f63),
          title: const Text('Send SOS', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<String>(
                  value: selectedEmergency,
                  dropdownColor: const Color(0xff203554),
                  items: ['Medical', 'Fire', 'Police', 'Help'].map((
                    String value,
                  ) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(color: Colors.cyan),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      selectedEmergency = newValue;
                    }
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: messageController,
                  style: const TextStyle(color: Colors.cyan),
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Enter your message',
                    hintStyle: const TextStyle(color: Colors.cyan),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.cyan,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                if (messageController.text.isNotEmpty) {
                  await appState.broadcastSOS(
                    messageController.text,
                    selectedEmergency,
                  );
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('SOS Broadcasted Successfully!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Send', style: TextStyle(color: Colors.red)),
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
        return GestureDetector(
          onTap: () {
            _animationController.forward().then((_) {
              _animationController.reverse();
            });
            _showSOSDialog(context, appState);
          },
          child: ScaleTransition(
            scale: Tween<double>(begin: 1.0, end: 1.1).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Curves.easeInOut,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: appState.isSOS ? Colors.red : Colors.deepOrange,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: (appState.isSOS ? Colors.red : Colors.deepOrange)
                          .withValues(alpha: 0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    appState.isSOS ? "SOS ACTIVE" : "Push SOS",
                    style: const TextStyle(
                      fontSize: 45,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

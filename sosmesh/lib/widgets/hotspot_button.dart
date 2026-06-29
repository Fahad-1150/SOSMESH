import 'package:flutter/material.dart';

import '../screens/hotspot_chat_screen.dart';
import '../services/hotspot_chat_service.dart';
import '../services/hotspot_settings_service.dart';

class HotspotButton extends StatefulWidget {
  const HotspotButton({super.key});

  @override
  State<HotspotButton> createState() => _HotspotButtonState();
}

class _HotspotButtonState extends State<HotspotButton> {
  final HotspotChatService _service = HotspotChatService();
  final HotspotSettingsService _settingsService = HotspotSettingsService();
  bool _isStarting = false;

  Future<void> _showHotspotDialog() async {
    final action = await showDialog<_HotspotAction>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hotspot Chat'),
        content: Text(
          'turn hotspot and rename with an ip ex: 192.168.10.9\n\n'
          'Suggested hotspot name: ${HotspotChatService.suggestedHotspotName}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, _HotspotAction.cancel),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, _HotspotAction.openSettings),
            child: const Text('Open hotspot'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, _HotspotAction.startChat),
            child: const Text('Start chat'),
          ),
        ],
      ),
    );

    if (action == _HotspotAction.openSettings) {
      final opened = await _settingsService.openHotspotSettings();
      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Open hotspot settings manually.')),
        );
      }
      return;
    }

    if (action != _HotspotAction.startChat) {
      return;
    }

    setState(() {
      _isStarting = true;
    });

    try {
      await _service.start();
      if (!mounted) {
        return;
      }
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const HotspotChatScreen()),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not start hotspot chat server: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isStarting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      height: 70,
      child: ElevatedButton.icon(
        onPressed: _isStarting ? null : _showHotspotDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.cyan,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: _isStarting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.black,
                ),
              )
            : const Icon(Icons.wifi_tethering),
        label: const Text(
          'Hotspot Chat',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

enum _HotspotAction { cancel, openSettings, startChat }

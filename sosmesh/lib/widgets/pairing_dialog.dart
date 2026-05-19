import 'package:flutter/material.dart';
import '../models/device_model.dart';
import '../services/pairing_service.dart';

class PairingDialog extends StatefulWidget {
  final DeviceModel device;
  final String connectionType;
  final VoidCallback onPairingComplete;

  const PairingDialog({
    required this.device,
    required this.connectionType,
    required this.onPairingComplete,
    super.key,
  });

  @override
  State<PairingDialog> createState() => _PairingDialogState();
}

class _PairingDialogState extends State<PairingDialog> {
  final PairingService _pairingService = PairingService();
  bool _isPairing = false;
  bool _pairingSuccess = false;
  String _statusMessage = 'Ready to pair';

  @override
  void initState() {
    super.initState();
    _startPairing();
  }

  Future<void> _startPairing() async {
    setState(() {
      _isPairing = true;
      _statusMessage = 'Pairing with ${widget.device.name}...';
    });

    try {
      final success = await _pairingService.initiatepairing(
        widget.device,
        widget.connectionType,
      );

      if (mounted) {
        setState(() {
          _isPairing = false;
          _pairingSuccess = success;
          _statusMessage = success
              ? 'Pairing successful!'
              : 'Pairing failed. Please try again.';
        });

        if (success) {
          widget.onPairingComplete();
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) Navigator.pop(context);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPairing = false;
          _pairingSuccess = false;
          _statusMessage = 'Error: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xff16213e),
      title: Text(
        'Pair with Device',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xff0f3460),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                if (_isPairing)
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.cyan),
                  )
                else if (_pairingSuccess)
                  const Icon(Icons.check_circle, color: Colors.green, size: 48)
                else
                  const Icon(Icons.error, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  widget.device.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Type: ${widget.connectionType}',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
                const SizedBox(height: 16),
                Text(
                  _statusMessage,
                  style: TextStyle(
                    color: _pairingSuccess ? Colors.green : Colors.cyan,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (!_isPairing)
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              _pairingSuccess ? 'Done' : 'Close',
              style: const TextStyle(color: Colors.cyan),
            ),
          ),
      ],
    );
  }
}

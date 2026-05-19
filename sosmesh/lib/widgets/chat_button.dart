import 'package:flutter/material.dart';

class ChatButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isPaired;

  const ChatButton({required this.onPressed, this.isPaired = false, super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isPaired ? Colors.cyan : Colors.grey[700],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            isPaired ? 'Chat' : 'Pair',
            style: TextStyle(
              color: isPaired ? const Color(0xff0f3460) : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

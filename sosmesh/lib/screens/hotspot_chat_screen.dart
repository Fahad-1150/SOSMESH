import 'dart:async';

import 'package:flutter/material.dart';

import '../services/hotspot_chat_service.dart';

class HotspotChatScreen extends StatefulWidget {
  const HotspotChatScreen({super.key});

  @override
  State<HotspotChatScreen> createState() => _HotspotChatScreenState();
}

class _HotspotChatScreenState extends State<HotspotChatScreen> {
  final HotspotChatService _service = HotspotChatService();
  final TextEditingController _messageController = TextEditingController();
  StreamSubscription<List<HotspotChatMessage>>? _messagesSubscription;
  List<HotspotChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _messages = _service.messages;
    _messagesSubscription = _service.messagesStream.listen((messages) {
      if (!mounted) {
        return;
      }
      setState(() {
        _messages = messages;
      });
    });
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      return;
    }

    await _service.sendFromApp(message);
    _messageController.clear();
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0d1117),
      appBar: AppBar(
        title: const Text('Hotspot Chat'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xff161b22),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xff30363d)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _service.serverUrl,
                  style: const TextStyle(
                    color: Colors.cyan,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Ask the other person to connect to your hotspot and open this address in their browser.',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Text(
                      'Waiting for browser chat...',
                      style: TextStyle(color: Colors.grey[500], fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isMe = message.sender == 'Me';

                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.78,
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isMe
                                ? Colors.cyan
                                : const Color(0xff21262d),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message.sender,
                                style: TextStyle(
                                  color: isMe ? Colors.black87 : Colors.cyan,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                message.content,
                                style: TextStyle(
                                  color: isMe ? Colors.black : Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: const Color(0xff161b22),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[700]!),
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _sendMessage,
                  style: IconButton.styleFrom(backgroundColor: Colors.cyan),
                  icon: const Icon(Icons.send, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

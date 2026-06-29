import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'battery_service.dart';
import 'location_service.dart';

class HotspotChatMessage {
  const HotspotChatMessage({
    required this.sender,
    required this.content,
    required this.timestamp,
  });

  final String sender;
  final String content;
  final DateTime timestamp;

  Map<String, dynamic> toJson() => {
        'sender': sender,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
      };
}

class HotspotChatService {
  static final HotspotChatService _instance = HotspotChatService._internal();

  factory HotspotChatService() {
    return _instance;
  }

  HotspotChatService._internal();

  static const int defaultPort = 8080;
  static const int browserPort = 80;
  static const String suggestedHotspotName = 'SOSMESH-192.168.10.9';
  static const String suggestedBrowserIp = '192.168.10.9';

  final LocationService _locationService = LocationService();
  final BatteryService _batteryService = BatteryService();
  final List<WebSocket> _clients = [];
  final List<HotspotChatMessage> _messages = [];
  final StreamController<List<HotspotChatMessage>> _messagesController =
      StreamController<List<HotspotChatMessage>>.broadcast();

  HttpServer? _server;
  String _hostAddress = suggestedBrowserIp;
  int _port = defaultPort;

  bool get isRunning => _server != null;
  String get hostAddress => _hostAddress;
  int get port => _port;
  String get serverUrl => _port == browserPort
      ? 'http://$_hostAddress'
      : 'http://$_hostAddress:$_port';
  List<HotspotChatMessage> get messages => List.unmodifiable(_messages);
  Stream<List<HotspotChatMessage>> get messagesStream =>
      _messagesController.stream;

  Future<void> start() async {
    if (_server != null) {
      return;
    }

    _hostAddress = await _findLocalAddress() ?? suggestedBrowserIp;
    try {
      _server = await HttpServer.bind(InternetAddress.anyIPv4, browserPort);
      _port = browserPort;
    } catch (_) {
      _server = await HttpServer.bind(InternetAddress.anyIPv4, defaultPort);
      _port = defaultPort;
    }
    _server!.listen(
      _handleRequest,
      onError: (Object error) => debugPrint('Hotspot server error: $error'),
      onDone: () => debugPrint('Hotspot server stopped'),
    );
  }

  Future<void> stop() async {
    for (final client in List<WebSocket>.from(_clients)) {
      await client.close();
    }
    _clients.clear();
    await _server?.close(force: true);
    _server = null;
  }

  Future<void> sendFromApp(String content) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) {
      return;
    }

    _addMessage(
      HotspotChatMessage(
        sender: 'Me',
        content: trimmed,
        timestamp: DateTime.now(),
      ),
    );
  }

  Future<void> _handleRequest(HttpRequest request) async {
    if (request.uri.path == '/ws' &&
        WebSocketTransformer.isUpgradeRequest(request)) {
      final socket = await WebSocketTransformer.upgrade(request);
      _clients.add(socket);
      socket.add(
        jsonEncode({
          'type': 'history',
          'messages': _messages.map((message) => message.toJson()).toList(),
        }),
      );

      socket.listen(
        (dynamic data) => _handleSocketMessage(socket, data),
        onDone: () => _clients.remove(socket),
        onError: (_) => _clients.remove(socket),
      );
      return;
    }

    if (request.uri.path == '/status') {
      await _writeJson(request, await _buildStatusPayload());
      return;
    }

    await _writeHtml(request, await _buildChatPage());
  }

  void _handleSocketMessage(WebSocket socket, dynamic data) {
    try {
      final decoded = jsonDecode(data as String) as Map<String, dynamic>;
      final content = (decoded['content'] as String? ?? '').trim();
      if (content.isEmpty) {
        return;
      }

      _addMessage(
        HotspotChatMessage(
          sender: 'Browser user',
          content: content,
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      debugPrint('Invalid browser chat message: $e');
    }
  }

  void _addMessage(HotspotChatMessage message) {
    _messages.add(message);
    _messagesController.add(List.unmodifiable(_messages));
    _broadcast({'type': 'message', 'message': message.toJson()});
  }

  void _broadcast(Map<String, dynamic> payload) {
    final encoded = jsonEncode(payload);
    for (final client in List<WebSocket>.from(_clients)) {
      if (client.readyState == WebSocket.open) {
        client.add(encoded);
      } else {
        _clients.remove(client);
      }
    }
  }

  Future<Map<String, dynamic>> _buildStatusPayload() async {
    final position = await _locationService.getCurrentLocation();
    await _batteryService.updateBatteryStatus();

    return {
      'location': position == null
          ? 'Location unavailable'
          : '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}',
      'latitude': position?.latitude,
      'longitude': position?.longitude,
      'battery': _batteryService.batteryLevel,
      'batteryState': _batteryService.getBatteryStateText(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  Future<void> _writeJson(
    HttpRequest request,
    Map<String, dynamic> payload,
  ) async {
    request.response.headers.contentType = ContentType.json;
    request.response.write(jsonEncode(payload));
    await request.response.close();
  }

  Future<void> _writeHtml(HttpRequest request, String html) async {
    request.response.headers.contentType = ContentType.html;
    request.response.write(html);
    await request.response.close();
  }

  Future<String> _buildChatPage() async {
    final status = await _buildStatusPayload();
    final location = const HtmlEscape().convert(status['location'] as String);
    final battery = status['battery'];
    final batteryState = const HtmlEscape().convert(
      status['batteryState'] as String,
    );

    return '''
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>SOSMesh Hotspot Chat</title>
  <style>
    * { box-sizing: border-box; }
    body {
      margin: 0;
      font-family: Arial, sans-serif;
      background: #0d1117;
      color: #ffffff;
    }
    header {
      padding: 18px 16px;
      background: #b42318;
      font-weight: 700;
      font-size: 22px;
    }
    main {
      max-width: 720px;
      margin: 0 auto;
      padding: 16px;
    }
    .status {
      display: grid;
      gap: 8px;
      margin-bottom: 14px;
      padding: 14px;
      background: #161b22;
      border: 1px solid #30363d;
      border-radius: 8px;
    }
    .status div { line-height: 1.35; }
    .messages {
      min-height: 340px;
      max-height: 55vh;
      overflow-y: auto;
      padding: 12px;
      background: #010409;
      border: 1px solid #30363d;
      border-radius: 8px;
    }
    .msg {
      margin: 0 0 10px;
      padding: 10px 12px;
      border-radius: 8px;
      background: #21262d;
      word-wrap: break-word;
    }
    .msg.me { background: #0e7490; }
    .meta {
      display: block;
      margin-bottom: 4px;
      color: #c9d1d9;
      font-size: 12px;
      font-weight: 700;
    }
    form {
      display: flex;
      gap: 8px;
      margin-top: 12px;
    }
    input {
      flex: 1;
      min-width: 0;
      border: 1px solid #30363d;
      border-radius: 8px;
      padding: 12px;
      background: #161b22;
      color: #ffffff;
      font-size: 16px;
    }
    button {
      border: 0;
      border-radius: 8px;
      padding: 0 16px;
      background: #22d3ee;
      color: #08111f;
      font-weight: 700;
      font-size: 15px;
    }
  </style>
</head>
<body>
  <header>SOSMesh Hotspot Chat</header>
  <main>
    <section class="status">
      <div><strong>Location:</strong> <span id="location">$location</span></div>
      <div><strong>Battery:</strong> <span id="battery">$battery%</span> ($batteryState)</div>
      <div><strong>Status:</strong> <span id="connection">Connecting...</span></div>
    </section>
    <section class="messages" id="messages"></section>
    <form id="form">
      <input id="message" autocomplete="off" placeholder="Type your message..." />
      <button type="submit">Send</button>
    </form>
  </main>
  <script>
    const messages = document.getElementById('messages');
    const connection = document.getElementById('connection');
    const form = document.getElementById('form');
    const input = document.getElementById('message');
    const socket = new WebSocket('ws://' + location.host + '/ws');

    function addMessage(message) {
      const item = document.createElement('div');
      item.className = 'msg' + (message.sender === 'Browser user' ? ' me' : '');
      const meta = document.createElement('span');
      meta.className = 'meta';
      meta.textContent = message.sender + ' - ' + new Date(message.timestamp).toLocaleTimeString();
      const text = document.createElement('span');
      text.textContent = message.content;
      item.appendChild(meta);
      item.appendChild(text);
      messages.appendChild(item);
      messages.scrollTop = messages.scrollHeight;
    }

    socket.onopen = () => connection.textContent = 'Connected';
    socket.onclose = () => connection.textContent = 'Disconnected';
    socket.onerror = () => connection.textContent = 'Connection error';
    socket.onmessage = (event) => {
      const payload = JSON.parse(event.data);
      if (payload.type === 'history') {
        messages.innerHTML = '';
        payload.messages.forEach(addMessage);
      }
      if (payload.type === 'message') {
        addMessage(payload.message);
      }
    };

    form.addEventListener('submit', (event) => {
      event.preventDefault();
      const content = input.value.trim();
      if (!content || socket.readyState !== WebSocket.OPEN) return;
      socket.send(JSON.stringify({ content }));
      input.value = '';
    });
  </script>
</body>
</html>
''';
  }

  Future<String?> _findLocalAddress() async {
    try {
      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.IPv4,
      );

      for (final interface in interfaces) {
        for (final address in interface.addresses) {
          if (!address.isLoopback && address.address.startsWith('192.168.')) {
            return address.address;
          }
        }
      }

      for (final interface in interfaces) {
        for (final address in interface.addresses) {
          if (!address.isLoopback) {
            return address.address;
          }
        }
      }
    } catch (e) {
      debugPrint('Could not detect hotspot IP: $e');
    }

    return null;
  }
}

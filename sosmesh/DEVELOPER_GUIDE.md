# Chat Feature - Developer Guide

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                    UI Layer (Widgets)                   │
│  ┌───────────────┬──────────────┬──────────────────┐   │
│  │ ChatListScreen│ChatDetailScreen│NearbyDevices  │   │
│  └───────────────┴──────────────┴──────────────────┘   │
└─────────────────────────────────────────────────────────┘
                           ▲
                           │ (uses)
                           ▼
┌─────────────────────────────────────────────────────────┐
│              Service Layer (Logic)                      │
│  ┌──────────────┬────────────────┬───────────────┐    │
│  │ChatService   │PairingService  │BLEService    │    │
│  └──────────────┴────────────────┴───────────────┘    │
└─────────────────────────────────────────────────────────┘
                           ▲
                           │ (uses)
                           ▼
┌─────────────────────────────────────────────────────────┐
│           Data Layer (Database & Models)               │
│  ┌────────────────────────────────────────────────┐   │
│  │      ChatDatabaseService (SQLite)             │   │
│  │  ┌─────────────┬──────────┬─────────┐        │   │
│  │  │ messages    │ pairings │ devices │        │   │
│  │  └─────────────┴──────────┴─────────┘        │   │
│  └────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

## Data Models

### DeviceModel
Represents a discovered device
```dart
class DeviceModel {
  final String id;              // Unique identifier
  final String name;            // User-friendly name
  final String address;         // MAC address
  final String connectionType;  // 'bluetooth' or 'wifi'
  final DateTime discoveredTime;
  final int? rssi;             // Signal strength
  final ScanResult? scanResult; // BLE scan result
}
```

### MessageModel
Represents a single message
```dart
class MessageModel {
  final String id;            // Unique message ID
  final String senderId;      // Sender device ID
  final String senderName;    // Sender display name
  final String receiverId;    // Recipient device ID
  final String content;       // Message text
  final DateTime timestamp;   // When sent
  final String status;        // 'sent', 'delivered', 'read'
  final String messageType;   // 'text', 'image', etc.
}
```

### PairingModel
Represents a pairing between two devices
```dart
class PairingModel {
  final String id;              // Pairing ID
  final String device1Id;       // First device
  final String device1Name;
  final String device2Id;       // Second device
  final String device2Name;
  final DateTime pairingTime;   // When paired
  final bool isActive;          // Is pairing active
  final String connectionType;  // 'bluetooth' or 'wifi'
}
```

## Service Layer

### ChatService (Singleton)
High-level chat operations
```dart
// Core responsibilities
- Send/receive messages
- Manage conversations
- Handle pairings
- Search messages

// Key methods
sendMessage(receiverId, receiverName, content) → MessageModel
receiveMessage(senderId, senderName, content) → void
getConversation(deviceId) → List<MessageModel>
pairWithDevice(device, connectionType) → PairingModel
isPairedWithDevice(deviceId) → bool
```

### PairingService (Singleton)
Device pairing management
```dart
// Core responsibilities
- Initiate pairings
- Validate pairings
- Manage pairing state

// Key methods
initiatepairing(device, connectionType) → bool
getActivePairings() → List<PairingModel>
isDevicePaired(deviceId) → bool
validatePairing(pairing) → bool
```

### ChatDatabaseService (Singleton)
SQLite database operations
```dart
// Core responsibilities
- Message CRUD
- Pairing storage
- Device tracking
- Database initialization

// Key methods
insertMessage(message) → void
getConversation(deviceId) → List<MessageModel>
insertPairing(pairing) → void
getAllPairings() → List<PairingModel>
insertDevice(device) → void
```

## UI Components

### ChatListScreen
- Fetches all conversations from database
- Displays devices that are paired
- Shows last message preview
- Handles unread counts
- Supports pull-to-refresh

### ChatDetailScreen
- Displays full message history
- Provides message input UI
- Sends/receives messages
- Updates UI in real-time
- Shows message timestamps and status

### NearbyDevices Widget
- Scans for Bluetooth devices
- Shows top 3 nearby devices
- Handles pairing initiation
- Navigates to chat on success

## State Management

### AppStateProvider (ChangeNotifier)
Central state management using Provider pattern
```dart
// Manages
- Bluetooth status
- WiFi status
- Battery level
- Flash state
- SOS state
- Chat service instance

// Services
- BLEService
- LocationService
- SOSService
- BatteryService
- FlashlightService
- ConnectivityService
- ChatService
```

## Database Schema

### Messages
```sql
id              TEXT PRIMARY KEY
senderId        TEXT NOT NULL
senderName      TEXT NOT NULL
receiverId      TEXT NOT NULL
content         TEXT NOT NULL
timestamp       TEXT NOT NULL (ISO8601)
status          TEXT (sent|delivered|read)
messageType     TEXT (text|image|...)

INDEXES:
idx_messages_receiver ON receiverId
idx_messages_sender ON senderId
idx_messages_timestamp ON timestamp
```

### Pairings
```sql
id              TEXT PRIMARY KEY
device1Id       TEXT NOT NULL
device1Name     TEXT NOT NULL
device2Id       TEXT NOT NULL
device2Name     TEXT NOT NULL
pairingTime     TEXT NOT NULL (ISO8601)
isActive        INTEGER (0|1)
connectionType  TEXT (bluetooth|wifi)

INDEXES:
idx_pairings_device1 ON device1Id
idx_pairings_device2 ON device2Id
```

### Devices
```sql
id              TEXT PRIMARY KEY
name            TEXT NOT NULL
address         TEXT NOT NULL
connectionType  TEXT NOT NULL
discoveredTime  TEXT NOT NULL (ISO8601)
rssi            INTEGER (nullable)
lastSeen        TEXT NOT NULL (ISO8601)
```

## Extension Points

### Adding New Message Types
```dart
// 1. Update MessageModel
final String messageType;  // Add to model

// 2. Update database
// Already supports messageType field

// 3. Create UI handler
if (messageType == 'image') {
  // Display image widget
} else if (messageType == 'video') {
  // Display video widget
}
```

### Adding Message Encryption
```dart
// 1. Update MessageModel
final String? encryptedContent;

// 2. Update ChatService.sendMessage()
final encrypted = encryptMessage(content, deviceId);
message.copyWith(encryptedContent: encrypted);

// 3. Update ChatDetailScreen.build()
final decrypted = decryptMessage(message.encryptedContent);
```

### Adding Typing Indicators
```dart
// 1. Create TypingIndicatorModel
class TypingIndicatorModel {
  final String deviceId;
  final bool isTyping;
  final DateTime timestamp;
}

// 2. Add to database
CREATE TABLE typing_indicators...

// 3. Update ChatDetailScreen UI
StreamBuilder for real-time typing status
```

### Adding Message Reactions
```dart
// 1. Create ReactionModel
class ReactionModel {
  final String messageId;
  final String emoji;
  final String userId;
}

// 2. Add to database
CREATE TABLE reactions...

// 3. Update ChatDetailScreen UI
Add emoji reactions button
```

## Flow Diagrams

### Sending a Message
```
User types message
    ↓
Tap Send button
    ↓
ChatDetailScreen calls chatService.sendMessage()
    ↓
ChatService creates MessageModel
    ↓
ChatDatabaseService.insertMessage()
    ↓
SQLite INSERT
    ↓
UI refreshes (setState)
    ↓
Message appears in chat
```

### Receiving a Message
```
Network receives data
    ↓
App calls chatService.receiveMessage()
    ↓
ChatService creates MessageModel
    ↓
ChatDatabaseService.insertMessage()
    ↓
SQLite INSERT
    ↓
Notify UI (StreamBuilder or setState)
    ↓
Message appears in chat
```

### Pairing Devices
```
User taps device in NearbyDevices
    ↓
showModalBottomSheet with options
    ↓
User selects Bluetooth/WiFi
    ↓
showDialog(PairingDialog)
    ↓
PairingDialog calls pairingService.initiatepairing()
    ↓
ChatService.pairWithDevice()
    ↓
ChatDatabaseService.insertPairing()
    ↓
SQLite INSERT
    ↓
Navigate to ChatDetailScreen
    ↓
User can now send messages
```

## Error Handling

### Database Errors
```dart
try {
  await insertMessage(message);
} catch (e) {
  debugPrint('Error: $e');
  // Show snackbar to user
  // Fallback to in-memory storage
}
```

### Connection Errors
```dart
try {
  await pairWithDevice(device, connectionType);
} catch (e) {
  // Show pairing failed dialog
  // Suggest retry or different connection type
}
```

### Message Send Failures
```dart
try {
  final message = await sendMessage(...);
} catch (e) {
  // Keep in draft
  // Show retry button
  // Mark as failed status
}
```

## Testing Guide

### Unit Tests
```dart
// Test ChatService
test('sendMessage creates valid MessageModel', () {
  final message = chatService.sendMessage(...);
  expect(message.status, 'sent');
});

// Test MessageModel
test('MessageModel.toMap() and fromMap() work correctly', () {
  final original = MessageModel(...);
  final map = original.toMap();
  final restored = MessageModel.fromMap(map);
  expect(restored, original);
});
```

### Widget Tests
```dart
// Test ChatDetailScreen
testWidgets('Can send message', (WidgetTester tester) async {
  await tester.pumpWidget(ChatDetailScreen(device: testDevice));
  await tester.enterText(find.byType(TextField), 'Hello');
  await tester.tap(find.byIcon(Icons.send));
  expect(find.text('Hello'), findsOneWidget);
});
```

## Performance Considerations

1. **Database Indexes**: Query on receiver/sender is O(1) due to indexes
2. **Lazy Loading**: Messages loaded on-demand for conversation
3. **Pagination**: Implement pagination for large conversations (future)
4. **Memory**: Use const constructors to reduce memory footprint
5. **Caching**: Consider caching recent conversations

## Security Considerations

1. **Data Storage**: Consider encryption for sensitive data
2. **Input Validation**: Sanitize message content
3. **Device Verification**: Verify device identity during pairing
4. **Transport Security**: Use TLS for network communication
5. **Local Storage**: Encrypt database at rest (future)

## Debugging

### Enable Debug Logs
```dart
// Already added debugPrint() throughout the code
// Use Android Studio Logcat to view

// Filter by:
// - ChatService
// - ChatDatabaseService
// - PairingService
// - ChatDetailScreen
```

### Database Inspection
```dart
// Use SQLite Browser to inspect the database
// Location: app documents folder/sosmesh_chat.db

// Query examples:
SELECT * FROM messages ORDER BY timestamp DESC;
SELECT * FROM pairings WHERE isActive = 1;
SELECT DISTINCT senderId, senderName FROM messages;
```

## Common Issues & Solutions

### Issue: Duplicate messages
**Solution**: Ensure unique message ID generation with UUID

### Issue: Slow message loading
**Solution**: 
- Add pagination
- Increase database indexes
- Reduce message batch size

### Issue: Pairing not persisting
**Solution**: Verify SQLite insert success with debug logs

### Issue: UI not updating after message send
**Solution**: Ensure setState() or provider.notifyListeners() called

---

**For questions or contributions, refer to the main documentation.**

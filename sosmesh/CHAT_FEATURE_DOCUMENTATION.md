# SOS Mesh Chat Feature Documentation

## Project Overview
The SOS Mesh Emergency App has been enhanced with a complete local mesh networking chat system. Users can now communicate with nearby devices using WiFi or Bluetooth, with all messages stored locally on their phones.

## New Features Added

### 1. **Find Nearby & Pair**
- Scan for nearby devices using Bluetooth or WiFi
- Select a device from the "Find Nearby" section
- Choose connection type (Bluetooth or WiFi)
- Automatic pairing process with visual feedback

### 2. **Chat System**
- Real-time messaging with paired devices
- Messages stored locally using SQLite database
- Message status tracking (sent, delivered, read)
- Chat history persistence
- Conversation list with last message preview
- Unread message counter

### 3. **Local Storage**
- All messages saved locally on the phone
- Database: `sosmesh_chat.db`
- Stores: Messages, Pairings, Device information
- Automatic database initialization on first run

---

## File Structure

### New Models (`lib/models/`)
```
├── device_model.dart       # Device/User model for discovered devices
├── message_model.dart      # Message model with serialization
└── pairing_model.dart      # Pairing information storage
```

### New Services (`lib/services/`)
```
├── chat_database_service.dart    # SQLite database operations
├── chat_service.dart             # Chat message and pairing logic
└── pairing_service.dart          # Device pairing management
```

### New Screens (`lib/screens/`)
```
├── chat_list_screen.dart      # Conversations list view
└── chat_detail_screen.dart    # Individual chat interface
```

### New Widgets (`lib/widgets/`)
```
├── pairing_dialog.dart    # Pairing status dialog
└── chat_button.dart       # Reusable chat action button
```

### Updated Files
```
├── nearby_devices.dart    # Added pairing and chat navigation
├── bottom_nav.dart       # Added "Chat" button
└── app_state_provider.dart # Added ChatService initialization
```

---

## How It Works

### User Flow

1. **Finding Devices**
   - Open the app
   - Go to "Find Nearby" section
   - App automatically scans for Bluetooth devices
   - Tap on any device to see options

2. **Pairing**
   - Select "Pair via Bluetooth" or "Pair via WiFi"
   - Wait for pairing confirmation
   - Device is now paired for chatting

3. **Chatting**
   - Tap the "Chat" button (amber color) in bottom navigation
   - Select a conversation from the list
   - Type and send messages
   - Messages appear instantly in the chat

4. **Message Storage**
   - All messages automatically saved locally
   - No internet required
   - Full chat history available offline

---

## Database Schema

### Messages Table
```sql
CREATE TABLE messages (
  id TEXT PRIMARY KEY,
  senderId TEXT NOT NULL,
  senderName TEXT NOT NULL,
  receiverId TEXT NOT NULL,
  content TEXT NOT NULL,
  timestamp TEXT NOT NULL,
  status TEXT DEFAULT 'sent',      -- 'sent', 'delivered', 'read'
  messageType TEXT DEFAULT 'text'  -- 'text', 'image', etc.
)
```

### Pairings Table
```sql
CREATE TABLE pairings (
  id TEXT PRIMARY KEY,
  device1Id TEXT NOT NULL,
  device1Name TEXT NOT NULL,
  device2Id TEXT NOT NULL,
  device2Name TEXT NOT NULL,
  pairingTime TEXT NOT NULL,
  isActive INTEGER DEFAULT 1,
  connectionType TEXT NOT NULL    -- 'bluetooth', 'wifi'
)
```

### Devices Table
```sql
CREATE TABLE devices (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  address TEXT NOT NULL,
  connectionType TEXT NOT NULL,
  discoveredTime TEXT NOT NULL,
  rssi INTEGER,
  lastSeen TEXT NOT NULL
)
```

---

## API Reference

### ChatService
```dart
// Initialize chat service
await chatService.initialize(deviceId, deviceName);

// Send message
final message = await chatService.sendMessage(
  receiverId: 'device_id',
  receiverName: 'Device Name',
  content: 'Hello!',
);

// Receive message
await chatService.receiveMessage(
  senderId: 'device_id',
  senderName: 'Device Name',
  content: 'Hi there!',
);

// Get conversation
final messages = await chatService.getConversation(deviceId);

// Get all chat partners
final partners = await chatService.getChatPartners();

// Pair with device
final pairing = await chatService.pairWithDevice(
  device: deviceModel,
  connectionType: 'bluetooth',
);

// Check if paired
final isPaired = await chatService.isPairedWithDevice(deviceId);
```

### PairingService
```dart
// Initiate pairing
final success = await pairingService.initiatepairing(device, 'bluetooth');

// Get active pairings
final pairings = await pairingService.getActivePairings();

// Check if paired
final isPaired = await pairingService.isDevicePaired(deviceId);

// Get pairing info
final pairing = await pairingService.getPairingInfo(deviceId);
```

### ChatDatabaseService
```dart
// Insert message
await dbService.insertMessage(messageModel);

// Get conversation
final messages = await dbService.getConversation(deviceId);

// Insert pairing
await dbService.insertPairing(pairingModel);

// Get all pairings
final pairings = await dbService.getAllPairings();
```

---

## UI Components

### Chat List Screen
- Shows all conversations with last message
- Unread message counter
- Last message timestamp
- Pull-to-refresh functionality
- Tap to open chat detail

### Chat Detail Screen
- Full message history
- Message bubbles (different styling for sent/received)
- Timestamps on messages
- Real-time message input
- Send button with validation

### Pairing Dialog
- Device selection confirmation
- Connection type display
- Real-time pairing status
- Success/error feedback

---

## Color Scheme
- **Primary Background**: `#0f3460` (dark blue)
- **Secondary Background**: `#16213e` (darker blue)
- **Primary Color**: `Colors.cyan` (chat default)
- **Chat Button**: `Colors.amber`
- **Status Colors**: 
  - Success: `Colors.green`
  - Error: `Colors.red`
  - Warning: `Colors.amber`

---

## Installation & Setup

1. **Dependencies** (already in pubspec.yaml):
   - `sqflite: ^2.4.1` - Local database
   - `path_provider: ^2.1.5` - File system access
   - `uuid: ^4.5.1` - Unique identifiers
   - `flutter_blue_plus: ^1.35.3` - Bluetooth
   - `connectivity_plus: ^6.1.0` - WiFi detection

2. **Initialization**:
   - Services auto-initialize in `AppStateProvider`
   - Database creates tables on first run
   - No manual setup required

3. **Permissions** (already configured):
   - Bluetooth scan/connect
   - Location access
   - WiFi access

---

## Future Enhancements

1. **Message Features**
   - Image/file sharing
   - Message reactions/emojis
   - Typing indicators
   - Read receipts

2. **Chat Features**
   - Group chats
   - Chat search
   - Message backups
   - Chat encryption

3. **Connection**
   - Direct P2P messaging
   - Mesh relay (message forwarding)
   - Connection quality indicator
   - Auto-reconnection

4. **UI Improvements**
   - Chat customization
   - Message notifications
   - Voice messages
   - Video call integration

---

## Troubleshooting

### Messages not saving?
- Check app permissions
- Ensure device has storage space
- Restart app

### Can't find devices?
- Enable Bluetooth/WiFi
- Check permissions are granted
- Ensure other device is discoverable
- Move devices closer together

### Chat not loading?
- Pull to refresh
- Close and reopen app
- Check database isn't corrupted

### Pairing fails?
- Try different connection type
- Disable and re-enable Bluetooth
- Check device is still nearby
- Restart both devices

---

## Notes
- Messages are stored permanently until manually deleted
- Database location: Device Documents folder
- No cloud sync (purely local storage)
- Messages work offline once stored
- Each device maintains its own message copies

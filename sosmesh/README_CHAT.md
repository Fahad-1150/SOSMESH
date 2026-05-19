# 🆘 SOS Mesh - Emergency Communication & Mesh Chat App

## Overview
**SOS Mesh** is a Flutter-based emergency communication app that combines critical SOS features with a local mesh networking chat system. Users can:

- 🆘 **Emergency SOS**: Broadcast distress signals with location
- 📍 **Location Sharing**: Share real-time location with contacts
- 🔦 **Flashlight**: Use phone flashlight for signaling
- 📱 **Mesh Chat**: Send messages via local Bluetooth/WiFi network
- 💾 **Offline-First**: All features work without internet
- 🔐 **Privacy**: No data stored on servers

---

## 🆕 What's New - Chat Feature!

### Local Mesh Networking Chat
Send messages to nearby users without internet!

**How It Works:**
1. 🔍 **Find Nearby** - Scan for devices using Bluetooth/WiFi
2. 🤝 **Pair Device** - Connect with a device
3. 💬 **Chat** - Send and receive messages instantly
4. 💾 **Local Storage** - All chats saved on your phone

### Key Features
- ✅ **Real-time Messaging** - Messages appear instantly
- ✅ **Full Chat History** - Access all past conversations
- ✅ **Dual Protocol** - Works with Bluetooth and WiFi
- ✅ **Message Status** - Track if messages are sent/delivered/read
- ✅ **Offline Support** - Chat works without internet connection
- ✅ **Auto-save** - All messages stored locally automatically

---

## 🚀 Quick Start

### Installation
```bash
# Clone the repository
git clone <repo-url>

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### First Steps
1. **Open the App** - All features are visible on home screen
2. **Enable Bluetooth** - For device discovery
3. **Find Nearby Users** - Tap the "Find Nearby" section
4. **Pair & Chat** - Select a device and start messaging

### Access Chat
- **Bottom Navigation** → Tap "Chat" button (amber)
- **View Conversations** → See all your chats
- **Continue Chatting** → Select any conversation

---

## 📱 Features

### 🆘 Emergency Features (Existing)
- One-tap SOS broadcast
- Location sharing with contacts
- Battery status monitoring
- Flashlight signaling
- Connection status indicator

### 💬 Chat Features (New)
- Find nearby devices
- Device pairing (Bluetooth/WiFi)
- Real-time messaging
- Conversation history
- Message status tracking
- Unread message counter

### 📊 Status Features
- Real-time battery level
- WiFi/Bluetooth connectivity
- Device location
- Signal strength indicator

---

## 📁 Project Structure

```
sosmesh/
├── lib/
│   ├── models/              # Data models
│   │   ├── device_model.dart
│   │   ├── message_model.dart
│   │   └── pairing_model.dart
│   │
│   ├── services/            # Business logic
│   │   ├── ble_service.dart
│   │   ├── chat_service.dart
│   │   ├── chat_database_service.dart
│   │   ├── pairing_service.dart
│   │   └── ... (other services)
│   │
│   ├── screens/             # App screens
│   │   ├── home_screen.dart
│   │   ├── chat_list_screen.dart
│   │   └── chat_detail_screen.dart
│   │
│   ├── widgets/             # UI components
│   │   ├── bottom_nav.dart
│   │   ├── nearby_devices.dart
│   │   ├── pairing_dialog.dart
│   │   └── ... (other widgets)
│   │
│   ├── providers/           # State management
│   │   └── app_state_provider.dart
│   │
│   └── main.dart            # App entry point
│
├── assets/                  # Images, fonts
├── pubspec.yaml            # Dependencies
└── README.md               # This file
```

---

## 🗄️ Database

All messages and pairings are stored locally in SQLite:
- **Location**: `{app_documents}/sosmesh_chat.db`
- **Tables**: messages, pairings, devices
- **Auto-creation**: Database created automatically on first run
- **Persistence**: Data persists even after app restart

---

## 📚 Documentation

### For Users
📖 [Quick Start Guide](./QUICK_START_GUIDE.md)
- How to use the chat feature
- Step-by-step instructions
- Tips and tricks
- Troubleshooting

### For Developers
📖 [Chat Feature Documentation](./CHAT_FEATURE_DOCUMENTATION.md)
- Complete technical specifications
- Database schema
- API reference
- Architecture details

📖 [Developer Guide](./DEVELOPER_GUIDE.md)
- Implementation details
- Extension points
- Testing guide
- Code examples

📖 [Implementation Summary](./IMPLEMENTATION_SUMMARY.md)
- What was added
- What was updated
- Statistics
- Future enhancements

---

## 🔧 Technology Stack

### Framework & Language
- **Flutter** - UI framework
- **Dart** - Programming language

### Key Libraries
- **flutter_blue_plus** - Bluetooth communication
- **connectivity_plus** - WiFi detection
- **sqflite** - Local database
- **provider** - State management
- **geolocator** - Location services
- **path_provider** - File system access

### Supported Platforms
- ✅ Android
- ✅ iOS
- ✅ Linux (with Bluetooth adapter)
- ✅ macOS (with Bluetooth adapter)
- ✅ Windows (with Bluetooth adapter)

---

## 🔐 Security & Privacy

### Data Safety
- ✅ All data stored **locally on your device**
- ✅ No data sent to any server
- ✅ No cloud synchronization
- ✅ Complete offline functionality

### Communication
- ✅ Direct device-to-device communication
- ✅ No intermediary servers
- ✅ Private local network only

---

## 🚀 Usage Examples

### Finding and Pairing
```dart
// User taps device in "Find Nearby"
// Selects "Pair via Bluetooth"
// System automatically handles pairing
// User is taken to chat screen
```

### Sending a Message
```dart
// User types message in chat input
// Taps send button
// Message is:
// 1. Sent to device
// 2. Saved locally
// 3. Displayed immediately
```

### Viewing Chat History
```dart
// User taps "Chat" in bottom nav
// Sees all conversations
// Taps any conversation to continue
// Full message history is available
```

---

## ⚙️ Permissions Required

The app requests these permissions:
- **Bluetooth**: For device discovery and communication
- **Location**: For Bluetooth scanning accuracy
- **WiFi**: For network connectivity detection
- **Storage**: For message database

All permissions are requested at runtime.

---

## 🐛 Troubleshooting

### Can't find devices?
- ✅ Enable Bluetooth on both devices
- ✅ Ensure target device is discoverable
- ✅ Move devices closer (within 10-100m)
- ✅ Restart Bluetooth on both devices

### Messages not sending?
- ✅ Verify pairing is complete
- ✅ Check devices are still in range
- ✅ Try different connection type (BT ↔ WiFi)
- ✅ Restart the app

### Chat history not visible?
- ✅ Check storage permission is granted
- ✅ Ensure device has free storage space
- ✅ Try refreshing the chat list
- ✅ Restart the app

---

## 🎯 Roadmap

### Phase 1: Current (✅ Complete)
- ✅ Local chat with Bluetooth/WiFi
- ✅ Message storage
- ✅ Device pairing
- ✅ Basic UI

### Phase 2: Planned
- [ ] Group chats
- [ ] Message reactions
- [ ] Typing indicators
- [ ] Image/file sharing

### Phase 3: Future
- [ ] Message encryption
- [ ] Voice messages
- [ ] Mesh relay (forwarding)
- [ ] Video calls

---

## 🤝 Contributing

Contributions are welcome! Areas for improvement:
- UI/UX enhancements
- Additional features
- Bug fixes
- Documentation improvements
- Performance optimization

---

## 📄 License

This project is provided as-is for educational and emergency communication purposes.

---

## 📞 Support

For issues, questions, or suggestions:
1. Check the [Quick Start Guide](./QUICK_START_GUIDE.md)
2. Review the [Developer Guide](./DEVELOPER_GUIDE.md)
3. Check troubleshooting sections
4. Create an issue in the repository

---

## 🎉 Getting Started

### First Time Setup
1. Install Flutter: https://flutter.dev/docs/get-started/install
2. Clone this repository
3. Run `flutter pub get`
4. Run `flutter run`
5. Enable Bluetooth on your device
6. Find nearby devices and start chatting!

### Tips
- Keep Bluetooth enabled for best experience
- Devices must be in range (typically 10-100 meters)
- WiFi pairing requires both devices on same network
- All data saved locally - no internet needed

---

## 🙏 Acknowledgments

Built with Flutter and community packages:
- flutter_blue_plus for Bluetooth
- connectivity_plus for network detection
- sqflite for local storage
- And many more...

---

## 📝 Changelog

### v1.1.0 - Chat Feature Release
- ✨ Added local mesh networking chat
- ✨ Device discovery and pairing
- ✨ Message storage and history
- ✨ Bluetooth/WiFi support
- ✨ Comprehensive documentation
- 🐛 Various bug fixes and improvements

### v1.0.0 - Initial Release
- 🆘 Emergency SOS feature
- 📍 Location sharing
- 🔦 Flashlight functionality
- 📱 Multi-platform support

---

**Stay Safe. Stay Connected. 🆘**

For more information, see the [QUICK_START_GUIDE.md](./QUICK_START_GUIDE.md) or [CHAT_FEATURE_DOCUMENTATION.md](./CHAT_FEATURE_DOCUMENTATION.md).

# Quick Start Guide - Chat Feature

## 🚀 How to Use the Chat Feature

### 1. Find Nearby Devices
1. Open the app on your device
2. Look for the **"Find Nearby"** section on the home screen
3. The app will automatically scan for Bluetooth devices nearby
4. Wait for devices to appear in the list

### 2. Pair with a Device
1. Tap on any device in the "Find Nearby" list
2. A bottom sheet will appear with two options:
   - **Pair via Bluetooth** (blue icon)
   - **Pair via WiFi** (yellow icon)
3. Select your preferred connection type
4. Wait for the pairing dialog to complete
5. Once successful, you'll be taken to the chat screen

### 3. Send Messages
1. Type your message in the text field at the bottom
2. Tap the **Send** button (cyan arrow icon)
3. Your message appears immediately in the chat
4. Messages are automatically saved to your phone

### 4. View All Conversations
1. Tap the **"Chat"** button (amber) in the bottom navigation
2. See all your active conversations
3. Tap any conversation to continue chatting
4. Pull down to refresh the list

---

## 💾 Data Storage

All data is stored **locally on your phone**:
- ✅ Messages saved permanently
- ✅ Chat history preserved
- ✅ Works completely offline
- ✅ No internet required
- ✅ No cloud upload

**Database Location**: `sosmesh_chat.db` in your app's documents folder

---

## 🔌 Connection Types

### Bluetooth
- **Best for**: Close range, peer-to-peer
- **Range**: 10-100 meters (depending on device)
- **Advantage**: Lower power consumption
- **Requirement**: Bluetooth enabled on both devices

### WiFi
- **Best for**: Same network connectivity
- **Range**: 30-100 meters (depending on router)
- **Advantage**: Usually faster
- **Requirement**: Both devices on same WiFi network

---

## 📊 Message Status

Messages show different statuses:
- **Sent** ✓ - Message left your device
- **Delivered** ✓✓ - Message reached recipient
- **Read** ✓✓✓ - Recipient viewed the message

---

## 🎨 User Interface

### Chat List Screen
Shows all your conversations with:
- Device name/avatar
- Last message preview
- Message timestamp
- Unread count badge (red circle with number)

### Chat Detail Screen
Shows conversation with:
- Full message history
- Message bubbles (cyan for you, blue for them)
- Timestamps on every message
- Real-time message input
- Send button

---

## ⚙️ Settings & Permissions

The app needs these permissions:
- ✅ Bluetooth (scan & connect)
- ✅ Location (for Bluetooth scanning)
- ✅ WiFi (network detection)
- ✅ Storage (message database)

All permissions are requested automatically on first run.

---

## 🐛 Troubleshooting

### "No devices found"
- ✅ Enable Bluetooth on both devices
- ✅ Make sure target device is discoverable
- ✅ Move devices closer together
- ✅ Restart Bluetooth scanning

### "Pairing fails"
- ✅ Try the other connection type
- ✅ Disable and re-enable Bluetooth
- ✅ Check if device is still nearby
- ✅ Restart the app

### "Messages not saving"
- ✅ Check storage space on phone
- ✅ Verify app has storage permission
- ✅ Restart the app
- ✅ Check if database file exists

### "Can't send message"
- ✅ Ensure device is paired
- ✅ Check connection is active
- ✅ Verify message is not empty
- ✅ Try re-pairing the device

---

## 📝 Tips & Tricks

1. **Quick Access**: Use the "Chat" button in bottom nav for fastest access
2. **Offline Chat**: All messages work offline - they sync when reconnected
3. **Clean Up**: Old discovered devices are automatically removed after 7 days
4. **Multiple Contacts**: You can pair with multiple devices and chat with all of them
5. **Message Search**: Use the search feature to find old messages

---

## 🔐 Privacy & Security

- Messages are stored **only on your device**
- No personal data is sent to any server
- All communication is direct device-to-device
- You control all your data locally

---

## 📱 Supported Platforms

- ✅ Android
- ✅ iOS
- ✅ Linux (with Bluetooth adapter)
- ✅ macOS (with Bluetooth adapter)
- ✅ Windows (with Bluetooth adapter)

---

## 🆘 Emergency Pairing Issues

If you can't find or pair with a device:

1. **Force close the app** and restart
2. **Toggle Bluetooth OFF then ON**
3. **Move devices closer** (within 3 meters)
4. **Ensure both devices discoverable**
5. **Try WiFi instead of Bluetooth**
6. **Restart both devices completely**

---

## 📞 Need Help?

If issues persist:
- Check the app logs in debug console
- Verify both devices have permissions granted
- Ensure adequate storage space
- Try on a different device

---

**Enjoy secure, offline mesh communication! 🎉**

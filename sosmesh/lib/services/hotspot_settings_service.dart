import 'dart:io';

import 'package:flutter/services.dart';

class HotspotSettingsService {
  static const MethodChannel _channel = MethodChannel('sosmesh/hotspot');

  Future<bool> openHotspotSettings() async {
    if (!Platform.isAndroid) {
      return false;
    }

    try {
      return await _channel.invokeMethod<bool>('openHotspotSettings') ?? false;
    } on PlatformException {
      return false;
    }
  }
}

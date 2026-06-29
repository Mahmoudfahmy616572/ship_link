import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class MapService {
  static bool? _useGoogleMaps;

  static const _channel = MethodChannel('com.ship_link/google_play_services');

  static Future<bool> get useGoogleMaps async {
    if (_useGoogleMaps != null) return _useGoogleMaps!;
    try {
      if (defaultTargetPlatform != TargetPlatform.android) {
        _useGoogleMaps = false;
      } else {
        final available = await _channel.invokeMethod<bool>('checkPlayServices');
        _useGoogleMaps = available ?? false;
      }
    } catch (_) {
      _useGoogleMaps = false;
    }
    return _useGoogleMaps!;
  }

  static void reset() => _useGoogleMaps = null;
}

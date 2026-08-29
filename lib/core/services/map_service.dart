import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The two rendering backends currently supported. This is purely a
/// capability/selection concept — it carries no provider-specific types.
enum MapProviderType { google, flutterMap }

class MapService {
  static bool? _useGoogleMaps;

  /// Opt-in legacy Google renderer. Phase 3 makes FlutterMap + MapTiler the
  /// primary renderer on ALL platforms; set this true only to validate the
  /// legacy Google fallback (e.g. Android + GMS) during migration.
  static bool enableGoogleRenderer = false;

  static const _channel = MethodChannel('com.ship_link/google_play_services');

  /// Pure selection rule. After Phase 3 the renderer is FlutterMap + MapTiler
  /// everywhere by default. Google is only selected when explicitly opted in
  /// AND available (Android + GMS). Selection no longer depends on GMS when the
  /// new renderer is primary.
  static MapProviderType selectProvider({
    required bool googleAvailable,
    required bool isWeb,
  }) {
    if (enableGoogleRenderer && !isWeb && googleAvailable) {
      return MapProviderType.google;
    }
    return MapProviderType.flutterMap;
  }

  /// Detects whether Google Play Services is available (Android only).
  static Future<bool> get useGoogleMaps async {
    if (_useGoogleMaps != null) return _useGoogleMaps!;
    try {
      if (defaultTargetPlatform != TargetPlatform.android) {
        _useGoogleMaps = false;
      } else {
        final available =
            await _channel.invokeMethod<bool>('checkPlayServices');
        _useGoogleMaps = available ?? false;
      }
    } catch (_) {
      _useGoogleMaps = false;
    }
    return _useGoogleMaps!;
  }

  /// The currently active map provider for this platform. Confines the
  /// Play-Services/MethodChannel detection to this single place.
  static Future<MapProviderType> get activeProvider async {
    if (kIsWeb) return MapProviderType.flutterMap;
    final google = await useGoogleMaps;
    return selectProvider(googleAvailable: google, isWeb: false);
  }

  static void reset() => _useGoogleMaps = null;
}

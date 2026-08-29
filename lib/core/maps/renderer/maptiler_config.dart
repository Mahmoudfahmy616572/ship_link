import 'package:flutter/foundation.dart';

/// Configuration boundary for the MapTiler-backed FlutterMap renderer.
///
/// Feature/UI/business code must NEVER reference tile URLs, API keys, or the
/// MapTiler hostname directly — only this module owns them. The FlutterMap
/// renderer (AdaptiveMap) reads [activeTileTemplate] and [activeAttribution].
///
/// API key is injected at build time via `--dart-define=MAPTILER_API_KEY=...`
/// and is never hard-coded here.
class MapTilerConfig {
  static const _host = 'https://api.maptiler.com/maps';
  static const _tileSize = '256';

  /// Light base style: MapTiler "positron" (clean, high-contrast streets).
  static const lightStyleId = 'positron';

  /// Dark base style: MapTiler "darkmatter" (readable dark base).
  static const darkStyleId = 'darkmatter';

  /// Required MapTiler attribution (present on every rendered map).
  static const attribution = '© MapTiler © OpenStreetMap contributors';

  /// OSM attribution used only by the graceful fallback below.
  static const _osmAttribution = '© OpenStreetMap contributors';

  /// Pure raster tile URL for a given MapTiler style + API key.
  /// Kept as a pure function so it can be unit-tested without a real secret.
  static String tileUrl({required String key, bool dark = false}) {
    final style = dark ? darkStyleId : lightStyleId;
    return '$_host/$style/$_tileSize/{z}/{x}/{y}.png?key=$key';
  }

  /// Graceful OSM fallback used ONLY when no MapTiler key is configured
  /// (e.g. local/dev builds). Production builds MUST supply a MapTiler key.
  static const osmFallbackTemplate =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  /// API key from build-time define. Never hard-coded.
  static String get apiKey =>
      const String.fromEnvironment('MAPTILER_API_KEY', defaultValue: '');

  static bool get isConfigured => apiKey.isNotEmpty;

  /// Active tile template: MapTiler when configured, otherwise OSM fallback.
  static String activeTileTemplate({bool dark = false}) {
    if (isConfigured) return tileUrl(key: apiKey, dark: dark);
    return osmFallbackTemplate;
  }

  /// Active attribution matching the active template source.
  static String get activeAttribution =>
      isConfigured ? attribution : _osmAttribution;
}

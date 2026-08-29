import 'package:ship_link/core/maps/models/map_coordinate.dart';

/// Region/configuration abstraction enabling future multi-country support
/// (Saudi Arabia, UAE, ...) without hard-coding Egypt throughout the app.
///
/// The region controls geo policies (country code, language, default map
/// position, search bounding box) only — it does NOT select the map renderer.
/// Map rendering stays independent via [AdaptiveMap].
class RegionConfig {
  final String countryCode;
  final String language;
  final MapCoordinate defaultCenter;
  final double defaultZoom;

  /// Search bounding box [west, south, east, north] used to bias/limit
  /// geocoding results to the active region.
  final List<double> boundingBox;

  const RegionConfig({
    required this.countryCode,
    required this.language,
    required this.defaultCenter,
    required this.defaultZoom,
    required this.boundingBox,
  });

  /// Egypt is the current primary region.
  static const egypt = RegionConfig(
    countryCode: 'EG',
    language: 'ar',
    defaultCenter: MapCoordinate(30.0444, 31.2357),
    defaultZoom: 12,
    boundingBox: [24.0, 21.0, 37.0, 32.0],
  );

  /// Active region. Swap here (or via runtime config) to expand later.
  static RegionConfig current = egypt;
}

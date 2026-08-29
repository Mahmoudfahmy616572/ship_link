import 'map_coordinate.dart';

/// Provider-independent reverse-geocoding result (Egypt-aware by default via
/// [RegionConfig]). Decouples feature code from the raw Nominatim response.
class GeocodingResult {
  final String formattedAddress;
  final MapCoordinate coordinate;
  final String? city;
  final String? governorate;
  final String? country;

  const GeocodingResult({
    required this.formattedAddress,
    required this.coordinate,
    this.city,
    this.governorate,
    this.country,
  });
}

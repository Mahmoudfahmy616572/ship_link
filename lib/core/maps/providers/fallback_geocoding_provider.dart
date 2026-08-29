import 'package:ship_link/core/maps/interfaces/geocoding_provider.dart';
import 'package:ship_link/core/maps/models/geocoding_result.dart';
import 'package:ship_link/core/maps/models/map_coordinate.dart';

/// Tries [primary]; on null/error falls back to [fallback]. Guarantees the
/// geocoding layer keeps working even before the new provider's key is
/// configured, and isolates provider-specific failures from the UI.
class FallbackGeocodingProvider implements GeocodingProvider {
  final GeocodingProvider primary;
  final GeocodingProvider fallback;

  const FallbackGeocodingProvider({
    required this.primary,
    required this.fallback,
  });

  @override
  Future<GeocodingResult?> reverseGeocode(MapCoordinate coordinate) async {
    try {
      final r = await primary.reverseGeocode(coordinate);
      if (r != null) return r;
    } catch (_) {}
    try {
      return await fallback.reverseGeocode(coordinate);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<GeocodingResult>> search(
    String query, {
    String? language,
    String? countryCode,
    int limit = 5,
  }) async {
    try {
      final r = await primary.search(
        query,
        language: language,
        countryCode: countryCode,
        limit: limit,
      );
      if (r.isNotEmpty) return r;
    } catch (_) {}
    try {
      return await fallback.search(
        query,
        language: language,
        countryCode: countryCode,
        limit: limit,
      );
    } catch (_) {
      return const [];
    }
  }
}

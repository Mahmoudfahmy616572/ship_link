import 'package:ship_link/core/maps/models/geocoding_result.dart';
import 'package:ship_link/core/maps/models/map_coordinate.dart';

/// Geocoding abstraction supporting both reverse (coordinate → address) and
/// forward (query → coordinates) lookups. Feature code depends only on this
/// interface and [GeocodingResult]; provider internals stay isolated.
abstract class GeocodingProvider {
  Future<GeocodingResult?> reverseGeocode(MapCoordinate coordinate);

  Future<List<GeocodingResult>> search(
    String query, {
    String? language,
    String? countryCode,
    int limit = 5,
  });
}

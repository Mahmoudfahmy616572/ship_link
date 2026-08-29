import 'package:ship_link/core/maps/maps.dart';
import 'package:ship_link/core/maps/models/geocoding_result.dart';
import 'package:ship_link/core/maps/models/map_coordinate.dart';

/// Backward-compatible facade used by legacy callers (e.g. location picker).
/// The actual logic now flows through the [GeocodingProvider] abstraction
/// (`geocodingService`) — MapTiler primary with Nominatim fallback — so this
/// thin shim keeps old callers working without provider-specific code.
class AddressResult {
  final String fullAddress;
  final String governorate;
  final String city;
  final String road;
  final double lat;
  final double lng;

  AddressResult({
    required this.fullAddress,
    required this.governorate,
    required this.city,
    required this.road,
    required this.lat,
    required this.lng,
  });
}

class GeocodingService {
  static Future<AddressResult?> reverseGeocode(double lat, double lng) async {
    final result =
        await geocodingService.reverseGeocode(MapCoordinate(lat, lng));
    if (result == null) return null;
    return AddressResult(
      fullAddress: result.formattedAddress,
      governorate: result.governorate ?? '',
      city: result.city ?? '',
      road: '',
      lat: lat,
      lng: lng,
    );
  }
}

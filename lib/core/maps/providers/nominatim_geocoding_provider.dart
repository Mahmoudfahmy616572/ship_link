import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ship_link/core/maps/interfaces/geocoding_provider.dart';
import 'package:ship_link/core/maps/models/geocoding_result.dart';
import 'package:ship_link/core/maps/models/map_coordinate.dart';
import 'package:ship_link/core/maps/region/region_config.dart';

/// Fallback geocoding provider: OpenStreetMap Nominatim (forward + reverse).
///
/// Used as the fallback behind [MapTilerGeocodingProvider]. No API key, but
/// must respect Nominatim's usage policy (identify via User-Agent, low rate).
/// Egypt filtering uses `countrycodes=eg`; Arabic via `accept-language`.
class NominatimGeocodingProvider implements GeocodingProvider {
  static const _base = 'https://nominatim.openstreetmap.org/search';
  static const _reverse = 'https://nominatim.openstreetmap.org/reverse';

  final http.Client? _client;

  NominatimGeocodingProvider({http.Client? client}) : _client = client;

  @override
  Future<GeocodingResult?> reverseGeocode(MapCoordinate coordinate) async {
    try {
      final uri = Uri.parse(_reverse).replace(queryParameters: {
        'format': 'jsonv2',
        'lat': '${coordinate.latitude}',
        'lon': '${coordinate.longitude}',
        'addressdetails': '1',
      });
      final client = _client ?? http.Client();
      final res = await client.get(uri, headers: {
        'User-Agent': 'ShipLink/1.0',
        'Accept-Language': RegionConfig.current.language,
      });
      if (_client == null) client.close();
      if (res.statusCode != 200) return null;

      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final address = json['address'] as Map<String, dynamic>? ?? {};
      final displayName = json['display_name'] as String? ?? '';

      final governorate =
          address['state'] ?? address['region'] ?? '';
      final city = address['city'] ??
          address['town'] ??
          address['village'] ??
          address['county'] ??
          '';
      final road = address['road'] ?? address['street'] ?? '';
      final country = address['country'] as String? ?? '';

      final parts = <String>[
        if (governorate.isNotEmpty) governorate,
        if (city.isNotEmpty) city,
        if (road.isNotEmpty) road,
      ];
      final cleanAddress = parts.isNotEmpty ? parts.join(', ') : displayName;

      return GeocodingResult(
        formattedAddress: cleanAddress,
        coordinate: coordinate,
        city: city,
        governorate: governorate,
        country: country,
      );
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
      final uri = Uri.parse(_base).replace(queryParameters: {
        'q': query,
        'format': 'json',
        'limit': '$limit',
        'countrycodes': countryCode ?? RegionConfig.current.countryCode,
        'accept-language': language ?? RegionConfig.current.language,
      });
      final client = _client ?? http.Client();
      final res = await client.get(uri, headers: {'User-Agent': 'ShipLink/1.0'});
      if (_client == null) client.close();
      if (res.statusCode != 200) return const [];
      final list = jsonDecode(res.body) as List;
      return list.map((e) {
        final m = e as Map<String, dynamic>;
        final lat = double.tryParse(m['lat'] as String? ?? '') ?? 0;
        final lng = double.tryParse(m['lon'] as String? ?? '') ?? 0;
        final addr = (m['address'] as Map<String, dynamic>? ?? {});
        final display = m['display_name'] as String? ?? '';
        return GeocodingResult(
          formattedAddress: display,
          coordinate: MapCoordinate(lat, lng),
          city: addr['city'] ?? addr['town'] ?? addr['village'] ?? addr['county'],
          governorate: addr['state'] ?? addr['region'],
          country: addr['country'],
        );
      }).toList();
    } catch (_) {
      return const [];
    }
  }
}

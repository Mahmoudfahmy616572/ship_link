import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ship_link/core/maps/interfaces/geocoding_provider.dart';
import 'package:ship_link/core/maps/models/geocoding_result.dart';
import 'package:ship_link/core/maps/models/map_coordinate.dart';
import 'package:ship_link/core/maps/renderer/maptiler_config.dart';
import 'package:ship_link/core/maps/region/region_config.dart';

/// Primary geocoding provider: MapTiler Geocoding API (forward + reverse).
///
/// Reuses the same [_apiKey] as the map tiles. Egypt filtering is
/// done server-side via `bbox` + `country=EG`, and `language=ar` for Arabic.
/// The only place that knows the MapTiler geocoding endpoint and response
/// (GeoJSON FeatureCollection) shape. When unconfigured it returns null/empty
/// so the [FallbackGeocodingProvider] can use Nominatim.
class MapTilerGeocodingProvider implements GeocodingProvider {
  final http.Client? _client;
  final String? _apiKeyOverride;

  MapTilerGeocodingProvider({http.Client? client, String? apiKey})
      : _client = client,
        _apiKeyOverride = apiKey;

  String get _apiKey => _apiKeyOverride ?? MapTilerConfig.apiKey;

  bool get isConfigured => _apiKey.isNotEmpty;

  String _bbox() {
    final b = RegionConfig.current.boundingBox;
    return '${b[0]},${b[1]},${b[2]},${b[3]}';
  }

  @override
  Future<GeocodingResult?> reverseGeocode(MapCoordinate coordinate) async {
    if (!isConfigured) return null;
    final uri = Uri.parse(
      'https://api.maptiler.com/geocoding/${coordinate.longitude},${coordinate.latitude}.json',
    ).replace(queryParameters: {
      'key': _apiKey,
      'language': RegionConfig.current.language,
      'limit': '1',
    });

    try {
      final client = _client ?? http.Client();
      final res = await client.get(uri, headers: {'User-Agent': 'ShipLink/1.0'});
      if (_client == null) client.close();
      if (res.statusCode != 200) return null;
      return _parseCollection(jsonDecode(res.body), coordinate);
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
    if (!isConfigured) return const <GeocodingResult>[];
    final uri = Uri.parse('https://api.maptiler.com/geocoding/$query.json').replace(
      queryParameters: {
        'key': _apiKey,
        'bbox': _bbox(),
        'country': countryCode ?? RegionConfig.current.countryCode,
        'language': language ?? RegionConfig.current.language,
        'limit': '$limit',
      },
    );

    try {
      final client = _client ?? http.Client();
      final res = await client.get(uri, headers: {'User-Agent': 'ShipLink/1.0'});
      if (_client == null) client.close();
      if (res.statusCode != 200) return const <GeocodingResult>[];
      return _parseList(jsonDecode(res.body));
    } catch (_) {
      return const <GeocodingResult>[];
    }
  }

  GeocodingResult? _parseCollection(dynamic json, [MapCoordinate? fallback]) {
    final features = (json is Map) ? (json['features'] as List?) : null;
    if (features == null || features.isEmpty) return null;
    return _feature(features.first as Map<String, dynamic>, fallback);
  }

  List<GeocodingResult> _parseList(dynamic json) {
    final features = (json is Map) ? (json['features'] as List?) : null;
    if (features == null) return const <GeocodingResult>[];
    return features.map((f) => _feature(f as Map<String, dynamic>)).toList();
  }

  GeocodingResult _feature(Map<String, dynamic> feature, [MapCoordinate? fallback]) {
    final props = feature['properties'] as Map<String, dynamic>? ?? {};
    final geometry = feature['geometry'] as Map<String, dynamic>? ?? {};
    final coords = geometry['coordinates'] as List?;
    final coordinate = (coords != null && coords.length >= 2)
        ? MapCoordinate((coords[1] as num).toDouble(), (coords[0] as num).toDouble())
        : (fallback ?? const MapCoordinate(0, 0));

    final text = (feature['text'] as String?) ?? props['name'] ?? '';
    final placeName = (feature['place_name'] as String?) ?? text;

    return GeocodingResult(
      formattedAddress: placeName,
      coordinate: coordinate,
      city: props['city'] ?? props['town'] ?? props['municipality'],
      governorate: props['region'] ?? props['state'] ?? props['county'],
      country: props['country'],
    );
  }
}

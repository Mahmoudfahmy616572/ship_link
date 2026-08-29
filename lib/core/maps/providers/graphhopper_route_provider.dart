import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ship_link/core/maps/interfaces/route_service.dart';
import 'package:ship_link/core/maps/models/map_coordinate.dart';
import 'package:ship_link/core/maps/models/route_result.dart';
import 'package:ship_link/core/maps/providers/polyline_decoder.dart';

/// Primary Egypt routing provider: GraphHopper Directions API.
///
/// Global OSM-based coverage (incl. Egypt), commercial plans with SLA, returns
/// Google-compatible encoded geometry so [PolylineDecoder] is reused. ETA is
/// modeled (not live-traffic). The only place that knows the GraphHopper
/// endpoint, key, request shape, and response parsing.
///
/// API key injected via `--dart-define=GRAPHHOPPER_API_KEY=...`; when absent the
/// provider reports unconfigured and the [FallbackRouteService] uses Google.
class GraphHopperRouteProvider implements RouteService {
  static const _base = 'https://graphhopper.com/api/1/route';

  final http.Client? _client;
  final String _apiKey;

  GraphHopperRouteProvider({
    http.Client? client,
    String? apiKey,
  })  : _client = client,
        _apiKey =
            apiKey ?? const String.fromEnvironment('GRAPHHOPPER_API_KEY', defaultValue: '');

  bool get isConfigured => _apiKey.isNotEmpty;

  @override
  Future<RouteResult?> getRoute({
    required MapCoordinate origin,
    required MapCoordinate destination,
  }) async {
    if (!isConfigured) return null;

    final uri = Uri.parse(_base).replace(queryParameters: {
      'point': [
        '${origin.latitude},${origin.longitude}',
        '${destination.latitude},${destination.longitude}',
      ],
      'vehicle': 'car',
      'points_encoded': 'true',
      'instructions': 'false',
      'calc_points': 'true',
      'key': _apiKey,
    });

    try {
      final client = _client ?? http.Client();
      final response = await client.get(uri);
      if (_client == null) client.close();

      if (response.statusCode != 200) return null;
      final data = json.decode(response.body) as Map<String, dynamic>;
      final paths = data['paths'] as List?;
      if (paths == null || paths.isEmpty) return null;

      final path = paths[0] as Map<String, dynamic>;
      final encoded = path['points'] as String?;
      if (encoded == null) return null;

      final points = PolylineDecoder.decode(encoded);
      final distance = (path['distance'] as num?)?.toDouble() ?? 0;
      final timeMs = (path['time'] as num?)?.toDouble() ?? 0;

      return RouteResult(
        polylinePoints: points,
        distanceMeters: distance,
        durationSeconds: (timeMs / 1000).round(),
        distanceText: distance > 0 ? '${(distance / 1000).toStringAsFixed(1)} km' : '',
        durationText: timeMs > 0 ? '${(timeMs / 60000).round()} min' : '',
        provider: 'graphhopper',
        isApproximate: false,
      );
    } catch (_) {
      return null;
    }
  }
}

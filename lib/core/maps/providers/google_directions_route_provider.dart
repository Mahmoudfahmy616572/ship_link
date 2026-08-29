import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ship_link/core/config.dart';
import 'package:ship_link/core/maps/interfaces/route_service.dart';
import 'package:ship_link/core/maps/models/map_coordinate.dart';
import 'package:ship_link/core/maps/models/route_result.dart';
import 'package:ship_link/core/maps/providers/polyline_decoder.dart';

/// Current routing provider: Google Directions API.
///
/// This is the ONLY place that knows the Google endpoint, API key, request
/// format, response parsing, and polyline decoding. The tracking/feature
/// layer consumes [RouteResult] and is unaware of Google specifics.
class GoogleDirectionsRouteProvider implements RouteService {
  static const _baseUrl = 'https://maps.googleapis.com/maps/api/directions/json';

  @override
  Future<RouteResult?> getRoute({
    required MapCoordinate origin,
    required MapCoordinate destination,
  }) async {
    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'origin': '${origin.latitude},${origin.longitude}',
      'destination': '${destination.latitude},${destination.longitude}',
      'key': AppConfig.googleMapsApiKey,
      'mode': 'driving',
      'alternatives': 'false',
    });

    try {
      final response = await http.get(uri);
      if (response.statusCode != 200) return null;

      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data['status'] != 'OK') return null;

      final routes = data['routes'] as List?;
      if (routes == null || routes.isEmpty) return null;

      final route = routes[0] as Map<String, dynamic>;
      final legs = route['legs'] as List?;
      if (legs == null || legs.isEmpty) return null;

      final leg = legs[0] as Map<String, dynamic>;
      final distance = leg['distance'] as Map<String, dynamic>?;
      final duration = leg['duration'] as Map<String, dynamic>?;
      final overviewPolyline = route['overview_polyline'] as Map<String, dynamic>?;
      if (overviewPolyline == null) return null;

      final encoded = overviewPolyline['points'] as String?;
      if (encoded == null) return null;

      final points = decodePolyline(encoded);

      return RouteResult(
        polylinePoints: points,
        distanceMeters: (distance?['value'] as num?)?.toDouble() ?? 0,
        durationSeconds: (duration?['value'] as num?)?.toDouble()?.toInt() ?? 0,
        distanceText: distance?['text'] ?? '',
        durationText: duration?['text'] ?? '',
        provider: 'google_directions',
        isApproximate: false,
      );
    } catch (_) {
      return null;
    }
  }

  /// Decodes an encoded Google Maps polyline into neutral [MapCoordinate]s.
  static List<MapCoordinate> decodePolyline(String encoded) =>
      PolylineDecoder.decode(encoded);
}

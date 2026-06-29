import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ship_link/config.dart';
import 'package:ship_link/widgets/adaptive_map.dart';

class RouteInfo {
  final List<MapLatLng> polylinePoints;
  final String distanceText;
  final String durationText;

  const RouteInfo({
    required this.polylinePoints,
    required this.distanceText,
    required this.durationText,
  });
}

class DirectionsService {
  static const _baseUrl = 'https://maps.googleapis.com/maps/api/directions/json';

  Future<RouteInfo?> getRoute({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'origin': '$originLat,$originLng',
      'destination': '$destLat,$destLng',
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

      final points = _decodePolyline(encoded);

      return RouteInfo(
        polylinePoints: points,
        distanceText: distance?['text'] ?? '?',
        durationText: duration?['text'] ?? '?',
      );
    } catch (_) {
      return null;
    }
  }

  static List<MapLatLng> _decodePolyline(String encoded) {
    final points = <MapLatLng>[];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int shift = 0;
      int result = 0;
      int byte;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);
      final dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);
      final dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(MapLatLng(lat / 1e5, lng / 1e5));
    }

    return points;
  }
}

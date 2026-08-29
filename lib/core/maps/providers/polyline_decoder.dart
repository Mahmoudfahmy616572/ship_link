import 'package:ship_link/core/maps/models/map_coordinate.dart';

/// Decodes an encoded polyline (Google/GraphHopper-compatible encoding) into
/// neutral [MapCoordinate]s. Centralized so every routing provider uses one
/// implementation and feature code never sees provider-specific geometry.
class PolylineDecoder {
  static List<MapCoordinate> decode(String encoded) {
    final points = <MapCoordinate>[];
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
      final dlat = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);
      final dlng = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(MapCoordinate(lat / 1e5, lng / 1e5));
    }

    return points;
  }
}

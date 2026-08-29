import 'map_coordinate.dart';

/// Provider-independent description of a route between two coordinates.
/// Replaces the previous [RouteInfo] which was tied to the concrete
/// Directions implementation. Polyline points use [MapCoordinate] so the
/// tracking/feature layer never depends on Google or FlutterMap types.
class RouteResult {
  final List<MapCoordinate> polylinePoints;
  final double distanceMeters;
  final int durationSeconds;
  final String distanceText;
  final String durationText;
  final String provider;
  final bool isApproximate;

  const RouteResult({
    this.polylinePoints = const [],
    this.distanceMeters = 0,
    this.durationSeconds = 0,
    this.distanceText = '',
    this.durationText = '',
    this.provider = '',
    this.isApproximate = false,
  });
}

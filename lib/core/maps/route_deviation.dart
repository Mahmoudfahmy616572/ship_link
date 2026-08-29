import 'package:ship_link/core/maps/models/map_coordinate.dart';
import 'package:ship_link/core/services/driver/marker_interpolation.dart';

/// Route deviation detection (Phase 5 §33, §34). Measures how far the driver
/// is from the current route polyline using great-circle distance to each
/// segment, not a naive straight-line to the destination.
class RouteDeviation {
  const RouteDeviation({this.toleranceMeters = 40});

  final double toleranceMeters;

  double deviationMeters(
    MapCoordinate point,
    List<MapCoordinate> polyline,
  ) {
    if (polyline.length < 2) {
      if (polyline.isEmpty) return double.infinity;
      return distanceMeters(
        point.latitude,
        point.longitude,
        polyline.first.latitude,
        polyline.first.longitude,
      );
    }
    var min = double.infinity;
    for (var i = 0; i < polyline.length - 1; i++) {
      final d = _distanceToSegment(
        point,
        polyline[i],
        polyline[i + 1],
      );
      if (d < min) min = d;
    }
    return min;
  }

  bool isOffRoute(MapCoordinate point, List<MapCoordinate> polyline) =>
      deviationMeters(point, polyline) > toleranceMeters;

  double _distanceToSegment(
    MapCoordinate p,
    MapCoordinate a,
    MapCoordinate b,
  ) {
    final dLatAB = b.latitude - a.latitude;
    final dLngAB = b.longitude - a.longitude;
    final len2 = dLatAB * dLatAB + dLngAB * dLngAB;
    if (len2 == 0) {
      return distanceMeters(p.latitude, p.longitude, a.latitude, a.longitude);
    }
    // Project in degree space (valid for short segments) to keep units
    // consistent between numerator and denominator.
    var t = ((p.latitude - a.latitude) * dLatAB +
            (p.longitude - a.longitude) * dLngAB) /
        len2;
    t = t.clamp(0.0, 1.0);
    final projLat = a.latitude + t * dLatAB;
    final projLng = a.longitude + t * dLngAB;
    return distanceMeters(p.latitude, p.longitude, projLat, projLng);
  }
}

/// Controls route requests so they never flood the provider (Phase 5 §32, §35).
/// - rate-limits by minimum interval
/// - only fires on meaningful driver movement
/// - ignores out-of-order / stale responses via a monotonically increasing id
class RouteRefreshPolicy {
  RouteRefreshPolicy({
    this.minInterval = const Duration(seconds: 10),
    this.minMoveMeters = 25,
    this.routeMaxAge = const Duration(seconds: 60),
  });

  final Duration minInterval;
  final double minMoveMeters;
  final Duration routeMaxAge;

  DateTime? _lastRequestAt;
  MapCoordinate? _lastOrigin;
  DateTime? _lastRouteAt;
  int _seq = 0;

  /// Returns a request id if a refresh should be performed, otherwise null.
  /// Caller must pass the returned id to [accept] when applying the result.
  int? shouldRefresh({
    required MapCoordinate origin,
    required DateTime now,
  }) {
    if (_lastOrigin != null &&
        distanceMeters(
              origin.latitude,
              origin.longitude,
              _lastOrigin!.latitude,
              _lastOrigin!.longitude,
            ) <
            minMoveMeters) {
      return null;
    }
    if (_lastRequestAt != null &&
        now.difference(_lastRequestAt!) < minInterval) {
      return null;
    }
    _lastRequestAt = now;
    _lastOrigin = origin;
    _seq += 1;
    return _seq;
  }

  /// True when [requestId] is the latest request (no newer response arrived).
  bool accept(int requestId) => requestId == _seq;

  /// Like [shouldRefresh] but bypasses the minimum-movement guard so a detected
  /// route deviation can force a reroute. Still respects the minimum interval
  /// to avoid storms.
  int? forceRefresh({
    required MapCoordinate origin,
    required DateTime now,
  }) {
    if (_lastRequestAt != null &&
        now.difference(_lastRequestAt!) < minInterval) {
      return null;
    }
    _lastRequestAt = now;
    _lastOrigin = origin;
    _seq += 1;
    return _seq;
  }

  void markRouteApplied(DateTime at) => _lastRouteAt = at;

  bool isRouteStale(DateTime now) =>
      _lastRouteAt == null || now.difference(_lastRouteAt!) > routeMaxAge;
}

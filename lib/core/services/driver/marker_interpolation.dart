import 'dart:math' as math;

/// Marker motion helpers (Phase 5 §28, §29, §30). Pure so they can be unit
/// tested without a map or GPS.
class MarkerInterpolator {
  MarkerInterpolator(this.lat, this.lng);

  double lat;
  double lng;

  /// Moves the animated position a fraction toward [target], smoothing normal
  /// updates. If the target is implausibly far (> [snapDistanceMeters]) the
  /// marker snaps immediately to avoid dragging the icon across the map.
  void step({
    required double targetLat,
    required double targetLng,
    double snapDistanceMeters = 200,
    double ease = 0.25,
  }) {
    final gap = distanceMeters(lat, lng, targetLat, targetLng);
    if (gap > snapDistanceMeters) {
      lat = targetLat;
      lng = targetLng;
      return;
    }
    lat += (targetLat - lat) * ease;
    lng += (targetLng - lng) * ease;
  }

  bool closeTo(double otherLat, double otherLng, {double meters = 1}) =>
      distanceMeters(lat, lng, otherLat, otherLng) <= meters;
}

double distanceMeters(double lat1, double lng1, double lat2, double lng2) {
  const r = 6371000.0;
  final dLat = _rad(lat2 - lat1);
  final dLng = _rad(lng2 - lng1);
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_rad(lat1)) *
          math.cos(_rad(lat2)) *
          math.sin(dLng / 2) *
          math.sin(dLng / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return r * c;
}

double bearingBetween(double lat1, double lng1, double lat2, double lng2) {
  final dLng = _rad(lng2 - lng1);
  final y = math.sin(dLng) * math.cos(_rad(lat2));
  final x = math.cos(_rad(lat1)) * math.sin(_rad(lat2)) -
      math.sin(_rad(lat1)) * math.cos(_rad(lat2)) * math.cos(dLng);
  return (_deg(math.atan2(y, x)) + 360) % 360;
}

double lerpLatLng(double a, double b, double t) => a + (b - a) * t;

double _rad(double d) => d * math.pi / 180;
double _deg(double r) => r * 180 / math.pi;

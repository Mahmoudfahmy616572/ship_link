/// A simple geographic coordinate used by the external navigation abstraction.
class NavCoordinate {
  final double latitude;
  final double longitude;

  const NavCoordinate(this.latitude, this.longitude);

  @override
  String toString() => '$latitude,$longitude';
}

/// Supported travel modes for external navigation requests.
enum TravelMode {
  driving,
  walking,
  bicycling,
  transit;

  String get mapsValue {
    switch (this) {
      case TravelMode.driving:
        return 'driving';
      case TravelMode.walking:
        return 'walking';
      case TravelMode.bicycling:
        return 'bicycling';
      case TravelMode.transit:
        return 'transit';
    }
  }
}

/// Provider-independent request describing where the driver wants to navigate.
///
/// The origin is optional: when omitted the external app navigates from the
/// device's live current location. The destination is always required.
class NavigationRequest {
  final NavCoordinate? origin;
  final NavCoordinate destination;
  final String? originLabel;
  final String? destinationLabel;
  final TravelMode travelMode;

  const NavigationRequest({
    this.origin,
    required this.destination,
    this.originLabel,
    this.destinationLabel,
    this.travelMode = TravelMode.driving,
  });

  /// True when the request has a usable destination (and origin, if provided).
  ///
  /// Rejects coordinates outside valid ranges and the (0,0) sentinel which is
  /// almost always missing-data rather than a real location.
  bool get isValid {
    if (!_isValidCoord(destination.latitude, destination.longitude)) return false;
    if (origin != null &&
        !_isValidCoord(origin!.latitude, origin!.longitude)) {
      return false;
    }
    return true;
  }

  static bool _isValidCoord(double lat, double lng) {
    if (lat < -90 || lat > 90) return false;
    if (lng < -180 || lng > 180) return false;
    if (lat == 0 && lng == 0) return false;
    if (lat.isNaN || lng.isNaN || lat.isInfinite || lng.isInfinite) return false;
    return true;
  }
}

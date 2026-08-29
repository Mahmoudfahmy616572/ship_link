/// Neutral, validated geographic coordinate used across the domain, routing,
/// and geocoding layers. It does NOT depend on any map provider (Google Maps,
/// FlutterMap, latlong2). Renderer-specific types ([MapLatLng]) are adapted
/// from this via [MapCoordinateAdapter].
class MapCoordinate {
  final double latitude;
  final double longitude;

  const MapCoordinate(this.latitude, this.longitude);

  bool get isValid =>
      latitude >= -90 &&
      latitude <= 90 &&
      longitude >= -180 &&
      longitude <= 180;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MapCoordinate &&
          other.latitude == latitude &&
          other.longitude == longitude;

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;

  @override
  String toString() => 'MapCoordinate($latitude, $longitude)';
}

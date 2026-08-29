/// Typed representation of a driver's live location coming from Supabase
/// Realtime (`driver_locations`). Replaces raw `Map<String, dynamic>` handling
/// with validation so invalid coordinates never reach the map renderer.
class DriverLocation {
  final String driverId;
  final double latitude;
  final double longitude;
  final String? status;
  final DateTime? updatedAt;
  final DateTime? lastSeen;
  final bool? isOnline;
  final double? heading;
  final double? speed;
  final double? accuracy;

  const DriverLocation({
    required this.driverId,
    required this.latitude,
    required this.longitude,
    this.status,
    this.updatedAt,
    this.lastSeen,
    this.isOnline,
    this.heading,
    this.speed,
    this.accuracy,
  });

  /// Parse a raw Supabase row into a [DriverLocation].
  /// Returns `null` when the data is missing, invalid or unsafe to render.
  static DriverLocation? tryParse(
    Map<String, dynamic> data, {
    String? fallbackDriverId,
  }) {
    final lat = (data['latitude'] as num?)?.toDouble();
    final lng = (data['longitude'] as num?)?.toDouble();
    if (lat == null || lng == null) return null;
    if (!isValidCoordinate(lat, lng)) return null;

    final id = (data['driver_id'] as String?) ?? fallbackDriverId;
    if (id == null || id.isEmpty) return null;

    DateTime? updated;
    final raw = data['updated_at'];
    if (raw is String) updated = DateTime.tryParse(raw);

    DateTime? seen;
    final rawSeen = data['last_seen'];
    if (rawSeen is String) seen = DateTime.tryParse(rawSeen);

    return DriverLocation(
      driverId: id,
      latitude: lat,
      longitude: lng,
      status: data['status'] as String?,
      updatedAt: updated,
      lastSeen: seen,
      isOnline: data['is_online'] as bool?,
      heading: (data['heading'] as num?)?.toDouble(),
      speed: (data['speed'] as num?)?.toDouble(),
      accuracy: (data['accuracy'] as num?)?.toDouble(),
    );
  }

  /// Validates that a coordinate pair is inside the legal WGS84 range.
  static bool isValidCoordinate(double latitude, double longitude) {
    return latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }

  /// Threshold after which a location is considered stale (no fresh GPS fix).
  static const staleThreshold = Duration(seconds: 60);

  /// True when the location is missing a timestamp or is older than [staleThreshold].
  bool get isStale {
    final u = updatedAt;
    if (u == null) return true;
    return DateTime.now().difference(u) > staleThreshold;
  }
}

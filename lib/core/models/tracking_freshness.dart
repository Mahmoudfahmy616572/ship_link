import 'package:ship_link/core/services/driver/tracking_state.dart';

/// Pure freshness model for a driver location received by the user app.
/// Thresholds are documented (Phase 5 §13, §25).
class TrackingFreshness {
  const TrackingFreshness({
    this.liveThreshold = const Duration(seconds: 15),
    this.recentThreshold = const Duration(seconds: 60),
    this.offlineThreshold = const Duration(seconds: 120),
  });

  final Duration liveThreshold;
  final Duration recentThreshold;
  final Duration offlineThreshold;

  LocationFreshness classify(DateTime? updatedAt, {DateTime? now}) {
    final t = now ?? DateTime.now();
    if (updatedAt == null) return LocationFreshness.unknown;
    final age = t.difference(updatedAt);
    if (age <= liveThreshold) return LocationFreshness.live;
    if (age <= recentThreshold) return LocationFreshness.recent;
    if (age <= offlineThreshold) return LocationFreshness.stale;
    return LocationFreshness.offline;
  }

  /// Combines driver's advertised status with freshness into a single semantic
  /// state the UI can render unambiguously (Phase 5 §13).
  /// - ONLINE + LIVE
  /// - ONLINE + STALE
  /// - OFFLINE
  /// - UNKNOWN
  UserOnlineState semantic({
    required DateTime? updatedAt,
    required bool isOnline,
    DateTime? now,
  }) {
    final f = classify(updatedAt, now: now);
    if (!isOnline) return UserOnlineState.offline;
    switch (f) {
      case LocationFreshness.live:
      case LocationFreshness.recent:
        return UserOnlineState.onlineLive;
      case LocationFreshness.stale:
        return UserOnlineState.onlineStale;
      case LocationFreshness.offline:
      case LocationFreshness.unknown:
        return UserOnlineState.offline;
    }
  }
}

enum UserOnlineState { onlineLive, onlineStale, offline }

/// Driver-side tracking session states (Phase 5 §3). Mutually exclusive and
/// idempotent: [active] can only be entered once, [stopped] is the terminal.
enum DriverTrackingState {
  stopped,
  starting,
  startingPermission,
  active,
  temporarilyUnavailable,
  reconnecting,
  stopping,
  error,
}

/// User-side tracking phase (Phase 5 §39). Distinguishes connection/routing
/// problems from driver availability problems.
enum UserTrackingPhase {
  initializing,
  invalidOrder,
  orderNotFound,
  waitingForDriver,
  loadingLocation,
  tracking,
  routeLoading,
  routeUnavailable,
  reconnecting,
  stale,
  offline,
  delivered,
  error,
}

/// Freshness classification for a received driver location (Phase 5 §25).
enum LocationFreshness {
  live,
  recent,
  stale,
  offline,
  unknown,
}

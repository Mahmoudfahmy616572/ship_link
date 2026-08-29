import 'package:flutter/foundation.dart';
import 'package:ship_link/core/services/driver/driver_tracking_session.dart';
import 'package:ship_link/core/services/driver/tracking_state.dart';

/// Public entry point for driver location tracking (Phase 5). Delegates to a
/// single [DriverTrackingSession] so there is exactly one writer to
/// `driver_locations` regardless of how many screens call [start]/[stop].
class DriverLocationService {
  final DriverTrackingSession session;

  DriverLocationService({DriverTrackingSession? session})
      : session = session ?? DriverTrackingSession();

  bool get isRunning => session.isRunning;

  ValueNotifier<DriverTrackingState> get stateNotifier => session.stateNotifier;

  /// Returns true only when tracking actually started (permission + driver id
  /// verified). Callers must reflect this in the UI's online toggle.
  Future<bool> start() => session.start();

  Future<void> stop() => session.stop();
}

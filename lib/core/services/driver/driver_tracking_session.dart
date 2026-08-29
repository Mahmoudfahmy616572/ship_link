import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ship_link/core/services/driver/location_quality_filter.dart';
import 'package:ship_link/core/services/driver/tracking_state.dart';

typedef PositionStreamFactory = Stream<Position> Function(LocationSettings settings);
typedef LocationRowWriter = Future<void> Function(Map<String, dynamic> row);
typedef DriverIdProvider = String? Function();
typedef PermissionRequester = Future<bool> Function();

/// Production-grade driver tracking session (Phase 5). Single owner of the
/// driver's location write path: one GPS stream, one timer, one Supabase
/// writer. Applies quality filtering, impossible-jump rejection, battery-aware
/// cadence, bounded retry + offline buffering, and platform background config.
class DriverTrackingSession {
  DriverTrackingSession({
    PositionStreamFactory? positionStreamFactory,
    LocationRowWriter? writer,
    DriverIdProvider? driverIdProvider,
    PermissionRequester? permissionRequester,
    this.filter = const LocationQualityFilter(),
  })  : _positionStreamFactory = positionStreamFactory ??
            ((settings) => Geolocator.getPositionStream(locationSettings: settings)),
        _writer = writer ?? _defaultWriter,
        _driverIdProvider = driverIdProvider ?? _defaultDriverId,
        _permissionRequester = permissionRequester ?? _defaultPermission;

  final PositionStreamFactory _positionStreamFactory;
  final LocationRowWriter _writer;
  final DriverIdProvider _driverIdProvider;
  final PermissionRequester _permissionRequester;
  final LocationQualityFilter filter;

  DriverTrackingState _state = DriverTrackingState.stopped;
  final ValueNotifier<DriverTrackingState> stateNotifier =
      ValueNotifier(DriverTrackingState.stopped);

  StreamSubscription<Position>? _sub;
  Timer? _heartbeat;
  Timer? _reconnect;
  bool _writing = false;
  bool _online = false;
  bool _moving = false;
  Position? _lastAccepted;
  Map<String, dynamic>? _pending;
  int _retryAttempt = 0;

  DriverTrackingState get state => _state;
  bool get isRunning =>
      _state == DriverTrackingState.active ||
      _state == DriverTrackingState.reconnecting ||
      _state == DriverTrackingState.temporarilyUnavailable;

  void _setState(DriverTrackingState s) {
    _state = s;
    stateNotifier.value = s;
  }

  Future<bool> start() async {
    if (isRunning) return true;
    _setState(DriverTrackingState.starting);

    final granted = await _permissionRequester();
    if (!granted) {
      _setState(DriverTrackingState.stopped);
      return false;
    }

    final driverId = _driverIdProvider();
    if (driverId == null) {
      _setState(DriverTrackingState.stopped);
      return false;
    }

    _online = true;
    _setState(DriverTrackingState.active);
    _subscribe();

    _heartbeat = Timer.periodic(const Duration(seconds: 30), (_) {
      _sendHeartbeat();
    });

    try {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) await _onPosition(last, isHeartbeat: true);
    } catch (_) {}

    return true;
  }

  Future<void> stop() async {
    _setState(DriverTrackingState.stopping);
    _online = false;
    _heartbeat?.cancel();
    _heartbeat = null;
    _reconnect?.cancel();
    _reconnect = null;
    await _sub?.cancel();
    _sub = null;
    try {
      await _writeOffline();
    } catch (_) {}
    _lastAccepted = null;
    _pending = null;
    _retryAttempt = 0;
    _setState(DriverTrackingState.stopped);
  }

  void _subscribe() {
    _sub?.cancel();
    _sub = _positionStreamFactory(_settings(_moving)).listen(
      (pos) => _onPosition(pos),
      onError: (_) {
        // GPS stream failure: keep online; heartbeat covers gaps.
        _setState(DriverTrackingState.temporarilyUnavailable);
      },
      cancelOnError: false,
    );
  }

  LocationSettings _settings(bool moving) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: moving ? LocationAccuracy.high : LocationAccuracy.medium,
        distanceFilter: moving ? 10 : 40,
        intervalDuration: Duration(seconds: moving ? 3 : 15),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'ShipLink',
          notificationText: 'مشاركة موقعك مع العميل أثناء التوصيل',
          notificationChannelName: 'Driver Location',
          notificationIcon: AndroidResource(name: 'ic_launcher', defType: 'mipmap'),
          enableWakeLock: false,
        ),
      );
    }
    return AppleSettings(
      accuracy: moving ? LocationAccuracy.high : LocationAccuracy.medium,
      activityType: ActivityType.automotiveNavigation,
      distanceFilter: moving ? 10 : 40,
      showBackgroundLocationIndicator: true,
    );
  }

  Future<void> _onPosition(Position pos, {bool isHeartbeat = false}) async {
    if (!_online) return;
    final result = filter.evaluate(pos, previous: _lastAccepted);
    if (!result.accept) {
      // Reject unreliable fixes; keep the last valid point. Do not publish
      // impossible jumps or stale/poor-accuracy positions.
      return;
    }
    _lastAccepted = pos;
    final nowMoving = (pos.speed != null && pos.speed! > 1.2) ||
        (pos.speed == null && !isHeartbeat);
    if (nowMoving != _moving) {
      _moving = nowMoving;
      _subscribe();
    }
    await _publish(_rowFor(pos));
  }

  Future<void> _sendHeartbeat() async {
    if (!_online) return;
    try {
      final pos = await Geolocator.getLastKnownPosition();
      if (pos != null) await _onPosition(pos, isHeartbeat: true);
    } catch (_) {
      if (_lastAccepted != null) await _publish(_rowFor(_lastAccepted!));
    }
  }

  Map<String, dynamic> _rowFor(Position pos) {
    final driverId = _driverIdProvider();
    return {
      'driver_id': driverId,
      'latitude': pos.latitude,
      'longitude': pos.longitude,
      'status': _online ? 'online' : 'offline',
      'updated_at': DateTime.now().toIso8601String(),
      'last_seen': DateTime.now().toIso8601String(),
      'is_online': _online,
      if (pos.heading != null && pos.heading! >= 0) 'heading': pos.heading,
      if (pos.speed != null && pos.speed! >= 0) 'speed': pos.speed,
      if (pos.accuracy != null && pos.accuracy! >= 0) 'accuracy': pos.accuracy,
    };
  }

  Future<void> _writeOffline() async {
    final driverId = _driverIdProvider();
    if (driverId == null) return;
    await _writer({
      'driver_id': driverId,
      'status': 'offline',
      'is_online': false,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _publish(Map<String, dynamic> row) async {
    if (_writing) {
      _pending = row; // keep only the latest; no historical replay
      return;
    }
    _writing = true;
    var attempt = 0;
    while (attempt < 3) {
      try {
        await _writer(row);
        _writing = false;
        if (_pending != null) {
          final next = _pending!;
          _pending = null;
          await _publish(next);
        } else if (_state == DriverTrackingState.reconnecting) {
          _setState(DriverTrackingState.active);
        }
        return;
      } catch (e) {
        attempt++;
        if (attempt >= 3) break;
        await Future.delayed(Duration(seconds: attempt));
      }
    }
    _writing = false;
    // Failed: keep latest and schedule a reconnect flush.
    _pending = row;
    _retryAttempt++;
    _setState(DriverTrackingState.reconnecting);
    _reconnect ??= Timer.periodic(const Duration(seconds: 15), (_) {
      if (_pending != null && !_writing) {
        final p = _pending!;
        _pending = null;
        _publish(p);
      }
    });
  }

  static String? _defaultDriverId() =>
      Supabase.instance.client.auth.currentUser?.id;

  static Future<bool> _defaultPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  static Future<void> _defaultWriter(Map<String, dynamic> row) async {
    await Supabase.instance.client.from('driver_locations').upsert(row);
  }
}

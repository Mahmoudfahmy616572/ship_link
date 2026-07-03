import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DriverLocationService {
  StreamSubscription<Position>? _subscription;
  Timer? _heartbeat;
  bool _isRunning = false;
  String? _driverId;
  double? _lastLat;
  double? _lastLng;

  bool get isRunning => _isRunning;

  Future<bool> _requestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<void> _updateLocation({double? lat, double? lng}) async {
    if (_driverId == null) return;
    try {
      await Supabase.instance.client.from('driver_locations').upsert({
        'driver_id': _driverId,
        if (lat != null && lng != null) ...{
          'latitude': lat,
          'longitude': lng,
        },
        'status': 'online',
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {}
  }

  /// Try to get the current position silently and update once.
  Future<void> _sendHeartbeat() async {
    try {
      final pos = await Geolocator.getLastKnownPosition();
      if (pos != null) {
        _lastLat = pos.latitude;
        _lastLng = pos.longitude;
        await _updateLocation(lat: pos.latitude, lng: pos.longitude);
      } else {
        await _updateLocation();
      }
    } catch (_) {
      await _updateLocation();
    }
  }

  Future<void> start() async {
    if (_isRunning) return;
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    _driverId = user.id;

    final hasPermission = await _requestPermission();
    if (!hasPermission) return;

    _isRunning = true;

    // Send initial location immediately
    await _sendHeartbeat();

    // Subscribe to GPS changes
    _subscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen(
      (pos) async {
        _lastLat = pos.latitude;
        _lastLng = pos.longitude;
        await _updateLocation(lat: pos.latitude, lng: pos.longitude);
      },
      onError: (_) {
        // GPS stream failed — keep driver online; heartbeat will cover it
      },
      cancelOnError: false,
    );

    // Heartbeat every 30s to keep driver online even when stationary
    _heartbeat = Timer.periodic(const Duration(seconds: 30), (_) {
      _sendHeartbeat();
    });
  }

  Future<void> stop() async {
    _isRunning = false;
    _heartbeat?.cancel();
    _heartbeat = null;
    await _subscription?.cancel();
    _subscription = null;
    if (_driverId != null) {
      try {
        await Supabase.instance.client.from('driver_locations').upsert({
          'driver_id': _driverId,
          'status': 'offline',
          'updated_at': DateTime.now().toIso8601String(),
        });
      } catch (_) {}
    }
    _driverId = null;
    _lastLat = null;
    _lastLng = null;
  }
}

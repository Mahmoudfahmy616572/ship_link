import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DriverLocationService {
  StreamSubscription<Position>? _subscription;
  bool _isRunning = false;
  String? _driverId;

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

  Future<void> start() async {
    if (_isRunning) return;
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    _driverId = user.id;

    final hasPermission = await _requestPermission();
    if (!hasPermission) return;

    _isRunning = true;
    _subscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((pos) async {
      if (_driverId == null) return;
      try {
        await Supabase.instance.client.from('driver_locations').upsert({
          'driver_id': _driverId,
          'latitude': pos.latitude,
          'longitude': pos.longitude,
          'status': 'online',
          'updated_at': DateTime.now().toIso8601String(),
        });
      } catch (_) {}
    });
  }

  Future<void> stop() async {
    _isRunning = false;
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
  }
}

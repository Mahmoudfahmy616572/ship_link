import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ship_link/utils/sizer.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ship_link/localization.dart';
import 'package:ship_link/views/shared/app_style.dart';
import 'package:ship_link/services/supabase_service.dart';
import 'package:ship_link/services/directions_service.dart';
import 'package:ship_link/widgets/adaptive_map.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DriverTrackingScreen extends StatefulWidget {
  const DriverTrackingScreen({super.key, required this.orderId});
  final String orderId;
  static String routName = '/driverTracking';

  @override
  State<DriverTrackingScreen> createState() => _DriverTrackingScreenState();
}

class _DriverTrackingScreenState extends State<DriverTrackingScreen> {
  AdaptiveMapController? _mapController;
  final _supabaseService = SupabaseService();
  StreamSubscription<Map<String, dynamic>>? _locationSub;
  RealtimeChannel? _orderChannel;

  String? _driverId;
  String _status = 'waiting';
  List<MapMarker> _markers = [];
  List<MapPolyline> _polylines = [];
  bool _loading = true;

  double? _driverLat;
  double? _driverLng;
  double? _userLat;
  double? _userLng;
  double? _distanceKm;
  int? _etaMin;

  @override
  void initState() {
    super.initState();
    _fetchOrder();
    _subscribeToOrder();
    _getUserLocation();
  }

  @override
  void dispose() {
    _locationSub?.cancel();
    _orderChannel?.unsubscribe();
    super.dispose();
  }

  Future<void> _getUserLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 8),
        ),
      );
      if (mounted) {
        setState(() {
          _userLat = pos.latitude;
          _userLng = pos.longitude;
        });
        await _updateRoute();
      }
    } catch (_) {}
  }

  Future<void> _fetchOrder() async {
    try {
      final orderId = int.tryParse(widget.orderId) ?? 0;
      final data = await Supabase.instance.client
          .from('orders')
          .select('driver_id, status, user_id')
          .eq('id', orderId)
          .maybeSingle();
      if (data != null && mounted) {
        _driverId = data['driver_id'] as String?;
        _status = data['status'] as String? ?? 'waiting';
        if (_driverId != null) _startTracking();
        _fetchUserLocation(data['user_id'] as String?);
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _fetchUserLocation(String? userId) async {
    if (userId == null) return;
    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select('latitude, longitude')
          .eq('id', userId)
          .maybeSingle();
      if (data != null && mounted) {
        setState(() {
          _userLat ??= (data['latitude'] as num?)?.toDouble();
          _userLng ??= (data['longitude'] as num?)?.toDouble();
        });
        await _updateRoute();
      }
    } catch (_) {}
  }

  void _subscribeToOrder() {
    _orderChannel = Supabase.instance.client
        .channel('order_track_${widget.orderId}')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'orders',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: widget.orderId,
          ),
          callback: (payload) {
            if (!mounted) return;
            final newId = payload.newRecord['driver_id'] as String?;
            if (newId != null && newId != _driverId) {
              _driverId = newId;
              _status = payload.newRecord['status'] as String? ?? _status;
              setState(() {});
              _startTracking();
            }
          },
        )
        .subscribe();
  }

  void _startTracking() {
    _locationSub?.cancel();
    if (_driverId == null) return;
    _locationSub = _supabaseService
        .getDriverLocation(_driverId!)
        .listen((data) {
      if (!mounted) return;
      final lat = data['latitude'] as double?;
      final lng = data['longitude'] as double?;
      if (lat != null && lng != null) {
        setState(() {
          _driverLat = lat;
          _driverLng = lng;
        });
        _updateRoute();
        _mapController?.animateTo(lat, lng, zoom: 13);
      }
    });
  }

  Future<void> _updateRoute() async {
    final dLat = _driverLat;
    final dLng = _driverLng;
    final uLat = _userLat;
    final uLng = _userLng;

    final markers = <MapMarker>[];
    final polylines = <MapPolyline>[];

    if (dLat != null && dLng != null) {
      markers.add(MapMarker(
        id: 'driver',
        latitude: dLat,
        longitude: dLng,
        icon: buildDriverMarker(),
        label: 'Driver',
      ));
    }

    if (uLat != null && uLng != null) {
      markers.add(MapMarker(
        id: 'user',
        latitude: uLat,
        longitude: uLng,
        icon: buildDestinationMarker(),
        label: 'You',
      ));
    }

    if (dLat != null && dLng != null && uLat != null && uLng != null) {
      try {
        final route = await DirectionsService().getRoute(
          originLat: dLat, originLng: dLng,
          destLat: uLat, destLng: uLng,
        );
        if (route != null && mounted) {
          final distKm = double.tryParse(route.distanceText.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
          final durMin = int.tryParse(route.durationText.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
          _distanceKm = distKm > 0 ? distKm : double.parse(Geolocator.distanceBetween(dLat, dLng, uLat, uLng).toStringAsFixed(1));
          _etaMin = durMin > 0 ? durMin : (Geolocator.distanceBetween(dLat, dLng, uLat, uLng) / 500).round().clamp(1, 999);
        } else {
          _fallbackDistance(dLat, dLng, uLat, uLng);
        }
      } catch (_) {
        _fallbackDistance(dLat, dLng, uLat, uLng);
      }

      polylines.add(MapPolyline(
        id: 'route',
        points: [
          MapLatLng(dLat, dLng),
          MapLatLng(uLat, uLng),
        ],
        color: const Color(0xFF2563EB),
        width: 4,
      ));
    }

    setState(() {
      _markers = markers;
      _polylines = polylines;
    });
  }

  void _fallbackDistance(double dLat, double dLng, double uLat, double uLng) {
    final dist = Geolocator.distanceBetween(dLat, dLng, uLat, uLng) / 1000;
    _distanceKm = double.parse(dist.toStringAsFixed(1));
    _etaMin = (dist / 0.5).round().clamp(1, 999);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(context.t.tr('track_your_orders')),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _statusBar(),
                Expanded(child: _buildMap()),
                _infoBar(),
              ],
            ),
    );
  }

  Widget _statusBar() {
    final isAssigned = _driverId != null;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      color: Colors.white,
      child: Row(
        children: [
          Container(
            width: 10.w,
            height: 10.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isAssigned
                  ? const Color(0xFF22C55E)
                  : const Color(0xFFF59E0B),
            ),
          ),
          SizedBox(width: 10.w),
          Text(
            isAssigned
                ? "Driver assigned — tracking live"
                : "Waiting for a driver...",
            style: appStyle(
              14,
              FontWeight.w500,
              isAssigned
                  ? const Color(0xFF111827)
                  : const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBar() {
    if (_distanceKm == null) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          _infoChip(Icons.directions_car, '$_distanceKm km'),
          SizedBox(width: 20.w),
          _infoChip(Icons.access_time, '$_etaMin min'),
          const Spacer(),
          GestureDetector(
            onTap: () => _mapController?.animateTo(
              _driverLat ?? 30.0444,
              _driverLng ?? 31.2357,
              zoom: 14,
            ),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Center',
                  style: TextStyle(color: Colors.white, fontSize: 13.sp)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: const Color(0xFF6B7280)),
        SizedBox(width: 4.w),
        Text(text,
            style: appStyle(14, FontWeight.w600, const Color(0xFF111827))),
      ],
    );
  }

  Widget _buildMap() {
    final lat = _driverLat ?? _userLat ?? 30.0444;
    final lng = _driverLng ?? _userLng ?? 31.2357;
    return AdaptiveMap(
      initialLatitude: lat,
      initialLongitude: lng,
      initialZoom: _driverLat != null ? 13 : 12,
      markers: _markers,
      polylines: _polylines,
      showMyLocation: true,
      showMyLocationButton: true,
      onMapCreated: (ctrl) => _mapController = ctrl,
    );
  }
}

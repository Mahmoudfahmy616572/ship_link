import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ship_link/core/models/driver_location.dart';
import 'package:ship_link/core/models/tracking_freshness.dart';
import 'package:ship_link/core/services/driver/marker_interpolation.dart';
import 'package:ship_link/core/services/supabase_service.dart';
import 'package:ship_link/core/maps/maps.dart';
import 'package:ship_link/core/maps/route_deviation.dart';
import 'package:ship_link/core/widgets/adaptive_map.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Resolves the order identifier passed to [DriverTrackingScreen].
String? parseTrackingOrderId(dynamic args) {
  if (args == null) return null;
  if (args is String) {
    final trimmed = args.trim();
    if (trimmed.isEmpty) return null;
    return trimmed;
  }
  if (args is int) return args.toString();
  if (args is num) return args.toInt().toString();
  return null;
}

enum _TrackPhase {
  initializing,
  invalidOrder,
  orderNotFound,
  waitingForDriver,
  loadingLocation,
  tracking,
  delivered,
  error,
}

class DriverTrackingScreen extends StatefulWidget {
  const DriverTrackingScreen({super.key, required this.orderId});
  final String orderId;
  static String routName = '/driverTracking';

  @override
  State<DriverTrackingScreen> createState() => _DriverTrackingScreenState();
}

class _TrackingState {
  final bool loading;
  final _TrackPhase phase;
  final String? errorMessage;
  final double? userLat;
  final double? userLng;
  final double? destLat;
  final double? destLng;
  final bool destIsDelivery;
  final double? driverLat;
  final double? driverLng;
  final bool isStale;
  final bool realtimeError;
  final bool routeUnavailable;
  final List<MapMarker> markers;
  final List<MapPolyline> polylines;
  final double? distanceKm;
  final int? etaMin;

  const _TrackingState({
    this.loading = true,
    this.phase = _TrackPhase.initializing,
    this.errorMessage,
    this.userLat,
    this.userLng,
    this.destLat,
    this.destLng,
    this.destIsDelivery = false,
    this.driverLat,
    this.driverLng,
    this.isStale = false,
    this.realtimeError = false,
    this.routeUnavailable = false,
    this.markers = const [],
    this.polylines = const [],
    this.distanceKm,
    this.etaMin,
  });

  _TrackingState copyWith({
    bool? loading,
    _TrackPhase? phase,
    String? errorMessage,
    double? userLat,
    double? userLng,
    double? destLat,
    double? destLng,
    bool? destIsDelivery,
    double? driverLat,
    double? driverLng,
    bool? isStale,
    bool? realtimeError,
    bool? routeUnavailable,
    List<MapMarker>? markers,
    List<MapPolyline>? polylines,
    double? distanceKm,
    int? etaMin,
    bool clearUserLat = false,
    bool clearUserLng = false,
    bool clearDestLat = false,
    bool clearDestLng = false,
    bool clearDriverLat = false,
    bool clearDriverLng = false,
    bool clearDistanceKm = false,
    bool clearEtaMin = false,
  }) {
    return _TrackingState(
      loading: loading ?? this.loading,
      phase: phase ?? this.phase,
      errorMessage: errorMessage ?? this.errorMessage,
      userLat: clearUserLat ? null : (userLat ?? this.userLat),
      userLng: clearUserLng ? null : (userLng ?? this.userLng),
      destLat: clearDestLat ? null : (destLat ?? this.destLat),
      destLng: clearDestLng ? null : (destLng ?? this.destLng),
      destIsDelivery: destIsDelivery ?? this.destIsDelivery,
      driverLat: clearDriverLat ? null : (driverLat ?? this.driverLat),
      driverLng: clearDriverLng ? null : (driverLng ?? this.driverLng),
      isStale: isStale ?? this.isStale,
      realtimeError: realtimeError ?? this.realtimeError,
      routeUnavailable: routeUnavailable ?? this.routeUnavailable,
      markers: markers ?? this.markers,
      polylines: polylines ?? this.polylines,
      distanceKm: clearDistanceKm ? null : (distanceKm ?? this.distanceKm),
      etaMin: clearEtaMin ? null : (etaMin ?? this.etaMin),
    );
  }
}

class _DriverTrackingScreenState extends State<DriverTrackingScreen>
    with SingleTickerProviderStateMixin {
  AdaptiveMapController? _mapController;
  final _supabaseService = SupabaseService();
  StreamSubscription<Map<String, dynamic>>? _locationSub;
  RealtimeChannel? _orderChannel;

  int? _orderIdInt;
  String? _driverId;
  String? _destAddress;
  bool _destResolved = false;
  String? _orderStatus;
  String? _driverName;
  String? _driverPhone;

  final ValueNotifier<_TrackingState> _state =
      ValueNotifier(const _TrackingState());

  // Marker interpolation state (Phase 5 §28, §29, §30).
  final MarkerInterpolator _interp = MarkerInterpolator(30.0444, 31.2357);
  double? _animLat;
  double? _animLng;
  double? _targetLat;
  double? _targetLng;
  double? _animHeading;
  double? _targetHeading;
  bool _animInit = false;

  // Camera follow vs explore (Phase 5 §31).
  bool _following = true;

  // Out-of-order guard (Phase 5 §27).
  DateTime? _lastAcceptedTs;

  // Route refresh concurrency + deviation (Phase 5 §32, §33, §34, §35).
  final RouteRefreshPolicy _routePolicy = RouteRefreshPolicy();
  final RouteDeviation _deviation = RouteDeviation();
  bool _routeInFlight = false;
  int? _routeSeq;
  List<MapCoordinate>? _lastRouteCoords;

  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _ticker.start();
    final id = parseTrackingOrderId(widget.orderId);
    if (id == null || int.tryParse(id) == null) {
      _state.value = const _TrackingState(
        loading: false,
        phase: _TrackPhase.invalidOrder,
      );
      return;
    }
    _orderIdInt = int.parse(id);
    _fetchOrder();
    _subscribeToOrder();
    _getUserLocation();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _locationSub?.cancel();
    _orderChannel?.unsubscribe();
    super.dispose();
  }

  void _onTick(Duration _) {
    if (_targetLat == null || _targetLng == null || !_animInit) return;
    _interp.lat = _animLat!;
    _interp.lng = _animLng!;
    _interp.step(targetLat: _targetLat!, targetLng: _targetLng!);
    _animLat = _interp.lat;
    _animLng = _interp.lng;
    if (_animHeading != null && _targetHeading != null) {
      var diff = _targetHeading! - _animHeading!;
      while (diff > 180) diff -= 360;
      while (diff < -180) diff += 360;
      _animHeading = (_animHeading! + diff * 0.15) % 360;
    }
    _refreshMarkerState();
  }

  Future<void> _getUserLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 8),
        ),
      );
      if (!mounted) return;
      _state.value = _state.value.copyWith(userLat: pos.latitude, userLng: pos.longitude);
      _resolveDestination(userLat: pos.latitude, userLng: pos.longitude);
      await _updateRoute(_nextRouteSeq());
    } catch (_) {}
  }

  Future<void> _fetchOrder() async {
    try {
      final data = await Supabase.instance.client
          .from('orders')
          .select('driver_id, status, user_id, delivery_lat, delivery_lng, delivery_address')
          .eq('id', _orderIdInt!)
          .maybeSingle();

      if (!mounted) return;
      if (data == null) {
        _state.value = const _TrackingState(loading: false, phase: _TrackPhase.orderNotFound);
        return;
      }

      final status = (data['status'] as String? ?? '').toLowerCase();
      _orderStatus = status;
      _driverId = data['driver_id'] as String?;
      _destAddress = data['delivery_address'] as String?;

      final dLat = (data['delivery_lat'] as num?)?.toDouble();
      final dLng = (data['delivery_lng'] as num?)?.toDouble();
      if (dLat != null && dLng != null && DriverLocation.isValidCoordinate(dLat, dLng)) {
        _state.value = _state.value.copyWith(destLat: dLat, destLng: dLng, destIsDelivery: true);
        _destResolved = true;
      } else {
        _fetchUserLocation(data['user_id'] as String?);
      }

      if (status == 'delivered' || status == 'cancelled') {
        _state.value = const _TrackingState(loading: false, phase: _TrackPhase.delivered);
        return;
      }

      _state.value = _state.value.copyWith(
        loading: false,
        phase: _driverId != null ? _TrackPhase.loadingLocation : _TrackPhase.waitingForDriver,
      );
      if (_driverId != null) {
        _fetchDriverProfile();
        _startTracking();
      }
    } catch (e) {
      debugPrint('[Tracking] order fetch failed: $e');
      if (mounted) {
        _state.value = const _TrackingState(
          loading: false,
          phase: _TrackPhase.error,
          errorMessage: 'Unable to load order details.',
        );
      }
    }
  }

  Future<void> _fetchUserLocation(String? userId) async {
    if (userId == null || _destResolved) return;
    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select('latitude, longitude')
          .eq('id', userId)
          .maybeSingle();
      if (data != null && mounted) {
        final lat = (data['latitude'] as num?)?.toDouble();
        final lng = (data['longitude'] as num?)?.toDouble();
        if (lat != null && lng != null) {
          _resolveDestination(userLat: lat, userLng: lng);
          await _updateRoute(_nextRouteSeq());
        }
      }
    } catch (_) {}
  }

  Future<void> _fetchDriverProfile() async {
    if (_driverId == null) return;
    try {
      final data = await Supabase.instance.client
          .from('drivers')
          .select('name, phone_number')
          .eq('id', _driverId!)
          .maybeSingle();
      if (!mounted || data == null) return;
      setState(() {
        _driverName =
            (data['name'] as String?)?.isNotEmpty == true ? data['name'] as String : null;
        _driverPhone = (data['phone_number'] as String?)?.isNotEmpty == true
            ? data['phone_number'] as String
            : null;
      });
    } catch (_) {}
  }

  void _resolveDestination({double? userLat, double? userLng}) {
    if (_destResolved) return;
    if (userLat != null && userLng != null) {
      _state.value = _state.value.copyWith(destLat: userLat, destLng: userLng, destIsDelivery: false);
    }
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
            value: _orderIdInt!,
          ),
          callback: (payload) {
            if (!mounted) return;
            final newId = payload.newRecord['driver_id'] as String?;
            final status = (payload.newRecord['status'] as String? ?? '').toLowerCase();
            _orderStatus = status;
            if (status == 'delivered' || status == 'cancelled') {
              _state.value = _state.value.copyWith(phase: _TrackPhase.delivered);
              _locationSub?.cancel();
              return;
            }
            if (newId != null && newId != _driverId) {
              _driverId = newId;
              _fetchDriverProfile();
              _state.value = _state.value.copyWith(phase: _TrackPhase.loadingLocation);
              _startTracking();
            }
          },
        )
        .subscribe();
  }

  void _startTracking() {
    _locationSub?.cancel();
    if (_driverId == null) return;
    _locationSub = _supabaseService.getDriverLocation(_driverId!).listen(
      (data) {
        if (!mounted) return;
        final loc = DriverLocation.tryParse(data, fallbackDriverId: _driverId);
        if (loc == null) return;
        _applyLocation(loc);
      },
      onError: (e) {
        debugPrint('[Tracking] location stream error: $e');
        if (mounted) _state.value = _state.value.copyWith(realtimeError: true);
      },
    );
  }

  void _applyLocation(DriverLocation loc) {
    // Out-of-order guard: ignore older events than the last applied (§27).
    if (loc.updatedAt != null && _lastAcceptedTs != null) {
      if (loc.updatedAt!.isBefore(_lastAcceptedTs!)) return;
    }
    _lastAcceptedTs = loc.updatedAt;

    final fresh = TrackingFreshness().classify(loc.updatedAt);
    final online = loc.isOnline ?? (loc.status == 'online');
    final semantic = TrackingFreshness().semantic(updatedAt: loc.updatedAt, isOnline: online);

    _targetLat = loc.latitude;
    _targetLng = loc.longitude;
    if (!_animInit) {
      _animLat = loc.latitude;
      _animLng = loc.longitude;
      _animInit = true;
      _interp.lat = loc.latitude;
      _interp.lng = loc.longitude;
    }
    // Heading: prefer reported heading when moving; else derive bearing (§30).
    if (loc.heading != null && loc.heading! >= 0 && (loc.speed ?? 0) > 1.0) {
      _targetHeading = loc.heading;
    } else if (_animLat != null && _animLng != null) {
      final b = bearingBetween(_animLat!, _animLng!, loc.latitude, loc.longitude);
      if ((loc.speed ?? 0) > 0.5) _targetHeading = b;
    }

    _state.value = _state.value.copyWith(
      driverLat: loc.latitude,
      driverLng: loc.longitude,
      isStale: semantic == UserOnlineState.onlineStale ||
          semantic == UserOnlineState.offline,
      phase: _TrackPhase.tracking,
      realtimeError: false,
    );

    if (_following && semantic != UserOnlineState.offline) {
      _mapController?.animateTo(loc.latitude, loc.longitude, zoom: 14);
    }

    // Route refresh + reroute (§32, §33, §34, §35).
    final now = DateTime.now();
    int? seq = _routePolicy.shouldRefresh(
      origin: MapCoordinate(loc.latitude, loc.longitude),
      now: now,
    );
    if (seq == null &&
        _lastRouteCoords != null &&
        _deviation.isOffRoute(MapCoordinate(loc.latitude, loc.longitude), _lastRouteCoords!) &&
        _routePolicy.isRouteStale(now)) {
      seq = _routePolicy.forceRefresh(
        origin: MapCoordinate(loc.latitude, loc.longitude),
        now: now,
      );
    }
    if (seq != null) _updateRoute(seq);
  }

  int _nextRouteSeq() {
    _routeSeq = _routePolicy.forceRefresh(
          origin: MapCoordinate(
            _state.value.driverLat ?? 30.0444,
            _state.value.driverLng ?? 31.2357,
          ),
          now: DateTime.now(),
        ) ??
        (_routeSeq ?? 0);
    return _routeSeq!;
  }

  Future<void> _updateRoute(int requestId) async {
    final st = _state.value;
    final dLat = st.driverLat;
    final dLng = st.driverLng;
    final uLat = st.destLat;
    final uLng = st.destLng;
    if (dLat == null || dLng == null || uLat == null || uLng == null) return;
    if (_routeInFlight) return;
    _routeInFlight = true;

    final markers = <MapMarker>[];
    markers.add(MapMarker(
      id: 'driver',
      latitude: _animLat ?? dLat,
      longitude: _animLng ?? dLng,
      icon: Transform.rotate(
        angle: (_animHeading ?? 0) * math.pi / 180,
        child: buildDriverMarker(),
      ),
      label: 'Driver',
    ));
    markers.add(MapMarker(
      id: 'destination',
      latitude: uLat,
      longitude: uLng,
      icon: st.destIsDelivery ? buildDestinationMarker() : buildOriginMarker(),
      label: st.destIsDelivery
          ? context.t.tr('tracking_delivery')
          : context.t.tr('tracking_you'),
    ));

    try {
      final route = await routeService.getRoute(
        origin: MapCoordinate(dLat, dLng),
        destination: MapCoordinate(uLat, uLng),
      );
      // Stale-response guard: a newer request may have started (§35).
      if (!_routePolicy.accept(requestId)) return;
      if (!mounted) return;

      if (route != null && route.polylinePoints.isNotEmpty) {
        _lastRouteCoords = route.polylinePoints;
        _routePolicy.markRouteApplied(DateTime.now());
        final polylines = [
          MapPolyline(
            id: 'route',
            points: route.polylinePoints.map((c) => c.toMapLatLng()).toList(),
            color: AppColors.routeLine,
            width: 4,
            casingColor: Colors.white,
            casingWidth: 8,
          )
        ];
        final distKm = route.distanceMeters > 0
            ? double.parse((route.distanceMeters / 1000).toStringAsFixed(1))
            : null;
        final durMin =
            route.durationSeconds > 0 ? (route.durationSeconds / 60).round() : null;
        _state.value = _state.value.copyWith(
          markers: markers,
          polylines: polylines,
          distanceKm: distKm,
          etaMin: durMin,
          routeUnavailable: false,
        );
      } else {
        _state.value = _state.value.copyWith(
          markers: markers,
          polylines: const [],
          distanceKm: null,
          etaMin: null,
          routeUnavailable: true,
        );
      }
    } catch (e) {
      debugPrint('[Tracking] route request failed: $e');
      if (!mounted) return;
      if (!_routePolicy.accept(requestId)) return;
      _state.value = _state.value.copyWith(
        markers: markers,
        polylines: const [],
        distanceKm: null,
        etaMin: null,
        routeUnavailable: true,
      );
    } finally {
      _routeInFlight = false;
    }
  }

  void _refreshMarkerState() {
    final dLat = _animLat ?? _state.value.driverLat;
    final dLng = _animLng ?? _state.value.driverLng;
    final markers = <MapMarker>[];
    if (dLat != null && dLng != null) {
      markers.add(MapMarker(
        id: 'driver',
        latitude: dLat,
        longitude: dLng,
        icon: Transform.rotate(
          angle: (_animHeading ?? 0) * math.pi / 180,
          child: buildDriverMarker(),
        ),
        label: 'Driver',
      ));
    }
    final uLat = _state.value.destLat;
    final uLng = _state.value.destLng;
    if (uLat != null && uLng != null) {
      markers.add(MapMarker(
        id: 'destination',
        latitude: uLat,
        longitude: uLng,
        icon: _state.value.destIsDelivery ? buildDestinationMarker() : buildOriginMarker(),
        label: _state.value.destIsDelivery
            ? context.t.tr('tracking_delivery')
            : context.t.tr('tracking_you'),
      ));
    }
    _state.value = _state.value.copyWith(markers: markers, polylines: _state.value.polylines);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<_TrackingState>(
      valueListenable: _state,
      builder: (_, st, __) {
        if (st.loading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (st.phase == _TrackPhase.invalidOrder ||
            st.phase == _TrackPhase.orderNotFound ||
            st.phase == _TrackPhase.error) {
          return _errorView(st);
        }
         if (st.phase == _TrackPhase.delivered) return _deliveredView();
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(context.t.tr('track_your_orders')),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0.5,
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  children: [
                    _statusBar(st),
                    if (_orderStatus != null &&
                        _orderStatus != 'delivered' &&
                        _orderStatus != 'cancelled')
                      TrackingProgressStepper(status: _orderStatus!),
                    Expanded(child: _buildMap(st)),
                    _infoBar(st),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _errorView(_TrackingState st) {
    final message = st.phase == _TrackPhase.invalidOrder
        ? 'Invalid order reference.'
        : st.phase == _TrackPhase.orderNotFound
            ? 'Order not found.'
            : st.errorMessage ?? 'Something went wrong.';
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.tr('track_your_orders')),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              SizedBox(height: 16.h),
              Text(message,
                  style: appStyle(16, FontWeight.w600, const Color(0xFF111827)),
                  textAlign: TextAlign.center),
              SizedBox(height: 16.h),
              ElevatedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Back')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _deliveredView() {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.tr('track_your_orders')),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline, size: 48, color: Color(0xFF22C55E)),
              SizedBox(height: 16.h),
              Text('This order is no longer being tracked.',
                  style: appStyle(16, FontWeight.w600, const Color(0xFF111827)),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusBar(_TrackingState st) {
    final Color dotColor;
    final String text;
    if (st.realtimeError) {
      dotColor = AppColors.error;
      text = context.t.tr('tracking_reconnecting');
    } else if (!_driverAssigned()) {
      dotColor = AppColors.pending;
      text = context.t.tr('waiting_for_driver');
    } else if (st.isStale) {
      dotColor = AppColors.pending;
      text = context.t.tr('tracking_stale');
    } else {
      dotColor = AppColors.success;
      text = context.t.tr('tracking_live');
    }
    final driverLabel = _driverName ??
        (_driverId != null ? context.t.tr('driver') : context.t.tr('no_driver_yet'));
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      color: Colors.white,
      child: Row(
        children: [
          Container(
              width: 10.w,
              height: 10.h,
              decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor)),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: appStyle(14, FontWeight.w600, AppColors.textPrimary)),
                if (_driverAssigned())
                  Padding(
                    padding: EdgeInsets.only(top: 2.h),
                    child: Text(driverLabel,
                        style: appStyle(12, FontWeight.w400, AppColors.textSecondary)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _driverAssigned() => _driverId != null;

  Future<void> _callDriver() async {
    if (_driverPhone == null) return;
    final uri = Uri.parse('tel:$_driverPhone');
    try {
      if (await canLaunchUrl(uri)) await launchUrl(uri);
    } catch (_) {}
  }

  Widget _infoBar(_TrackingState st) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (st.routeUnavailable)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
            color: const Color(0xFFFEF3C7),
            child: Text(context.t.tr('route_unavailable_note'),
                style: appStyle(12, FontWeight.w400, const Color(0xFF92400E))),
          ),
        if (st.distanceKm != null || _driverPhone != null)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
            ),
            child: Row(
              children: [
                if (st.distanceKm != null) ...[
                  _infoChip(Icons.directions_car, '${st.distanceKm} km'),
                  SizedBox(width: 16.w),
                  _infoChip(Icons.access_time, '${st.etaMin} min'),
                  SizedBox(width: 8.w),
                ],
                const Spacer(),
                if (_driverPhone != null)
                  Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: ElevatedButton.icon(
                      onPressed: _callDriver,
                      icon: const Icon(Icons.call, size: 16),
                      label: Text(context.t.tr('call_driver')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      ),
                    ),
                  ),
                GestureDetector(
                  onTap: () {
                    _following = true;
                    _mapController?.animateTo(
                      st.driverLat ?? 30.0444,
                      st.driverLng ?? 31.2357,
                      zoom: 14,
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(context.t.tr('recenter'),
                        style: TextStyle(color: Colors.white, fontSize: 13.sp)),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: const Color(0xFF6B7280)),
        SizedBox(width: 4.w),
        Text(text, style: appStyle(14, FontWeight.w600, const Color(0xFF111827))),
      ],
    );
  }

  Widget _buildMap(_TrackingState st) {
    final lat = st.driverLat ?? st.destLat ?? st.userLat ?? 30.0444;
    final lng = st.driverLng ?? st.destLng ?? st.userLng ?? 31.2357;
    return Stack(
      children: [
        AdaptiveMap(
          initialLatitude: lat,
          initialLongitude: lng,
          initialZoom: st.driverLat != null ? 13 : 12,
          markers: st.markers,
          polylines: st.polylines,
          showMyLocation: true,
          showMyLocationButton: true,
          onMapCreated: (ctrl) => _mapController = ctrl,
          onTap: (_) {
            // User is exploring: stop camera follow until they recenter (§31).
            if (_following) setState(() => _following = false);
          },
        ),
        if (!_following)
          Positioned(
            right: 12.w,
            bottom: 80.h,
            child: FloatingActionButton.small(
              heroTag: 'followDriver',
              backgroundColor: AppColors.primary,
              onPressed: () {
                _following = true;
                _mapController?.animateTo(
                  st.driverLat ?? lat,
                  st.driverLng ?? lng,
                  zoom: 14,
                );
              },
              child: const Icon(Icons.center_focus_strong, color: Colors.white),
            ),
          ),
      ],
    );
  }
}

/// Horizontal progress stepper reflecting the real driver-side order flow.
/// Steps map to actual statuses: accepted → picked_up → in_transit → delivered.
class TrackingProgressStepper extends StatelessWidget {
  final String status;
  const TrackingProgressStepper({super.key, required this.status});

  static const List<String> _labels = [
    'accepted',
    'picked_up',
    'in_transit',
    'delivered',
  ];

  static int stepForStatus(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return 0;
      case 'picked_up':
        return 1;
      case 'shipped':
      case 'in_transit':
        return 2;
      case 'delivered':
        return 3;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = stepForStatus(status);
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          for (int i = 0; i < _labels.length; i++) ...[
            _stepDot(context, i < current, i == current, _labels[i]),
            if (i < _labels.length - 1)
              Expanded(
                child: Container(
                  height: 2.h,
                  color: i < current ? AppColors.success : AppColors.border,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _stepDot(
      BuildContext context, bool done, bool active, String labelKey) {
    final color = done
        ? AppColors.success
        : (active ? AppColors.primary : AppColors.textDisabled);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18.w,
          height: 18.h,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          child: done
              ? const Icon(Icons.check, size: 12, color: Colors.white)
              : null,
        ),
        SizedBox(height: 4.h),
        Text(context.t.tr(labelKey),
            style: appStyle(10, FontWeight.w500, color)),
      ],
    );
  }
}

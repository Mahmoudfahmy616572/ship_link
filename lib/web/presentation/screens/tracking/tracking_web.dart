import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/core/widgets/adaptive_map.dart';
import 'package:ship_link/core/models/driver_location.dart';
import 'package:ship_link/core/services/supabase_service.dart';
import 'package:ship_link/core/maps/maps.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TrackingWeb extends StatefulWidget {
  final String? driverId;
  final int? orderId;

  const TrackingWeb({super.key, this.driverId, this.orderId});
  static String routName = '/tracking';

  @override
  State<TrackingWeb> createState() => _TrackingWebState();
}

enum _WebPhase { initializing, waiting, tracking, delivered, error, orderNotFound }

class _WebTrack {
  final List<MapMarker> markers;
  final List<MapPolyline> polylines;
  final bool stale;
  final bool realtimeError;
  final bool routeUnavailable;
  final double? distanceKm;
  final int? etaMin;
  final String? driverName;
  final String? driverPhone;
  final String? orderStatus;
  final _WebPhase phase;

  const _WebTrack({
    this.markers = const [],
    this.polylines = const [],
    this.stale = false,
    this.realtimeError = false,
    this.routeUnavailable = false,
    this.distanceKm,
    this.etaMin,
    this.driverName,
    this.driverPhone,
    this.orderStatus,
    this.phase = _WebPhase.initializing,
  });

  _WebTrack copyWith({
    List<MapMarker>? markers,
    List<MapPolyline>? polylines,
    bool? stale,
    bool? realtimeError,
    bool? routeUnavailable,
    double? distanceKm,
    int? etaMin,
    String? driverName,
    String? driverPhone,
    String? orderStatus,
    _WebPhase? phase,
    bool clearDistanceKm = false,
    bool clearEtaMin = false,
  }) =>
      _WebTrack(
        markers: markers ?? this.markers,
        polylines: polylines ?? this.polylines,
        stale: stale ?? this.stale,
        realtimeError: realtimeError ?? this.realtimeError,
        routeUnavailable: routeUnavailable ?? this.routeUnavailable,
        distanceKm: clearDistanceKm ? null : (distanceKm ?? this.distanceKm),
        etaMin: clearEtaMin ? null : (etaMin ?? this.etaMin),
        driverName: driverName ?? this.driverName,
        driverPhone: driverPhone ?? this.driverPhone,
        orderStatus: orderStatus ?? this.orderStatus,
        phase: phase ?? this.phase,
      );
}

class _TrackingWebState extends State<TrackingWeb> {
  AdaptiveMapController? _mapController;
  final SupabaseService _supabase = SupabaseService();
  final ValueNotifier<_WebTrack> _track =
      ValueNotifier(const _WebTrack(phase: _WebPhase.initializing));
  final ValueNotifier<bool> _loading = ValueNotifier(true);

  int? _orderIdInt;
  String? _driverId;
  double? _driverLat;
  double? _driverLng;
  double? _destLat;
  double? _destLng;
  bool _routeInFlight = false;
  double? _lastRouteLat;
  double? _lastRouteLng;
  bool _following = true;
  StreamSubscription<Map<String, dynamic>>? _locationSub;
  RealtimeChannel? _orderChannel;

  @override
  void initState() {
    super.initState();
    _setupTracking();
  }

  @override
  void dispose() {
    _locationSub?.cancel();
    _orderChannel?.unsubscribe();
    super.dispose();
  }

  Future<void> _setupTracking() async {
    String? driverId = widget.driverId;
    if (widget.orderId != null) {
      _orderIdInt = widget.orderId;
      try {
        final order = await Supabase.instance.client
            .from('orders')
            .select(
                'driver_id, status, delivery_lat, delivery_lng, delivery_address, user_id')
            .eq('id', widget.orderId!)
            .maybeSingle();
        if (order == null) {
          _loading.value = false;
          _track.value = const _WebTrack(phase: _WebPhase.orderNotFound);
          return;
        }
        final status = (order['status'] as String? ?? '').toLowerCase();
        final dId = order['driver_id'] as String?;
        if (dId != null) driverId = dId;
        final dl = (order['delivery_lat'] as num?)?.toDouble();
        final dn = (order['delivery_lng'] as num?)?.toDouble();
        if (dl != null &&
            dn != null &&
            DriverLocation.isValidCoordinate(dl, dn)) {
          _destLat = dl;
          _destLng = dn;
        }
        _track.value = _track.value.copyWith(orderStatus: status);
        if (status == 'delivered' || status == 'cancelled') {
          _loading.value = false;
          _track.value = const _WebTrack(phase: _WebPhase.delivered);
          return;
        }
        _subscribeToOrder();
      } catch (_) {
        _loading.value = false;
        _track.value = const _WebTrack(phase: _WebPhase.error);
        return;
      }
    }

    if (driverId == null) {
      _loading.value = false;
      _track.value = const _WebTrack(phase: _WebPhase.waiting);
      return;
    }

    _driverId = driverId;
    await _fetchDriverProfile(driverId);
    _startTracking();
  }

  void _subscribeToOrder() {
    if (_orderIdInt == null) return;
    _orderChannel = Supabase.instance.client
        .channel('order_web_track_${widget.orderId}')
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
            final status =
                (payload.newRecord['status'] as String? ?? '').toLowerCase();
            final newId = payload.newRecord['driver_id'] as String?;
            _track.value = _track.value.copyWith(orderStatus: status);
            if (status == 'delivered' || status == 'cancelled') {
              _locationSub?.cancel();
              _track.value = const _WebTrack(phase: _WebPhase.delivered);
              return;
            }
            if (newId != null && newId != _driverId) {
              _driverId = newId;
              _fetchDriverProfile(newId);
              _startTracking();
            }
          },
        )
        .subscribe();
  }

  Future<void> _fetchDriverProfile(String driverId) async {
    try {
      final data = await Supabase.instance.client
          .from('drivers')
          .select('name, phone_number')
          .eq('id', driverId)
          .maybeSingle();
      if (!mounted || data == null) return;
      final name = (data['name'] as String?)?.isNotEmpty == true
          ? data['name'] as String
          : null;
      final phone = (data['phone_number'] as String?)?.isNotEmpty == true
          ? data['phone_number'] as String
          : null;
      _track.value =
          _track.value.copyWith(driverName: name, driverPhone: phone);
    } catch (_) {}
  }

  void _startTracking() {
    _locationSub?.cancel();
    if (_driverId == null) {
      _track.value = _track.value.copyWith(phase: _WebPhase.waiting);
      return;
    }
    _track.value = _track.value.copyWith(phase: _WebPhase.tracking);
    _locationSub = _supabase.getDriverLocation(_driverId!).listen(
      (data) {
        if (!mounted) return;
        final loc = DriverLocation.tryParse(data, fallbackDriverId: _driverId);
        if (loc == null) return;
        _applyLocation(loc);
      },
      onError: (_) {
        if (mounted) _track.value = _track.value.copyWith(realtimeError: true);
      },
    );
  }

  void _applyLocation(DriverLocation loc) {
    _driverLat = loc.latitude;
    _driverLng = loc.longitude;

    final markers = <MapMarker>[
      MapMarker(
        id: 'driver',
        latitude: loc.latitude,
        longitude: loc.longitude,
        icon: buildDriverMarker(),
        label: context.t.tr('driver_location'),
      ),
    ];
    if (_destLat != null && _destLng != null) {
      markers.add(MapMarker(
        id: 'destination',
        latitude: _destLat!,
        longitude: _destLng!,
        icon: buildDestinationMarker(),
        label: context.t.tr('delivery'),
      ));
    }

    _track.value = _track.value.copyWith(
      markers: markers,
      stale: loc.isStale,
      realtimeError: false,
      phase: _WebPhase.tracking,
    );
    if (_following) _mapController?.animateTo(loc.latitude, loc.longitude);
    _maybeRoute();
    if (_loading.value) _loading.value = false;
  }

  Future<void> _maybeRoute() async {
    if (_driverLat == null ||
        _driverLng == null ||
        _destLat == null ||
        _destLng == null) {
      return;
    }
    if (_routeInFlight) return;
    final moved = _lastRouteLat == null ||
        _lastRouteLng == null ||
        Geolocator.distanceBetween(
              _lastRouteLat!,
              _lastRouteLng!,
              _driverLat!,
              _driverLng!,
            ) >
            25;
    if (!moved) return;

    _routeInFlight = true;
    _lastRouteLat = _driverLat;
    _lastRouteLng = _driverLng;
    try {
      final route = await routeService.getRoute(
        origin: MapCoordinate(_driverLat!, _driverLng!),
        destination: MapCoordinate(_destLat!, _destLng!),
      );
      if (!mounted) return;
      if (route != null && route.polylinePoints.isNotEmpty) {
        final distKm = route.distanceMeters > 0
            ? double.parse((route.distanceMeters / 1000).toStringAsFixed(1))
            : null;
        final durMin = route.durationSeconds > 0
            ? (route.durationSeconds / 60).round()
            : null;
        _track.value = _track.value.copyWith(
          polylines: [
            MapPolyline(
              id: 'route',
              points: route.polylinePoints.map((c) => c.toMapLatLng()).toList(),
              color: AppColors.routeLine,
              width: 4,
              casingColor: Colors.white,
              casingWidth: 8,
            )
          ],
          distanceKm: distKm,
          etaMin: durMin,
          routeUnavailable: false,
        );
      } else {
        _track.value = _track.value.copyWith(
          polylines: const [],
          distanceKm: null,
          etaMin: null,
          routeUnavailable: true,
        );
      }
    } catch (_) {
      if (mounted) {
        _track.value = _track.value.copyWith(
          polylines: const [],
          distanceKm: null,
          etaMin: null,
          routeUnavailable: true,
        );
      }
    } finally {
      _routeInFlight = false;
    }
  }

  Future<void> _callDriver() async {
    final phone = _track.value.driverPhone;
    if (phone == null) return;
    final uri = Uri.parse('tel:$phone');
    try {
      if (await canLaunchUrl(uri)) await launchUrl(uri);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _loading,
      builder: (_, loading, __) {
        if (loading) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        return ValueListenableBuilder<_WebTrack>(
          valueListenable: _track,
          builder: (_, track, __) {
            if (track.phase == _WebPhase.orderNotFound ||
                track.phase == _WebPhase.error) {
              return _errorView(track);
            }
            if (track.phase == _WebPhase.delivered) return _deliveredView();
            if (track.phase == _WebPhase.waiting && widget.orderId == null) {
              return _noActiveView();
            }
            return Scaffold(
              backgroundColor: const Color(0xFFF9FAFB),
              appBar: AppBar(
                title: Text(context.t.tr('live_tracking'),
                    style: appStyle(18, FontWeight.w600, const Color(0xFF111827))),
                backgroundColor: Colors.white,
                elevation: 0.5,
                actions: widget.orderId != null
                    ? [
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Center(
                            child: Text('#${widget.orderId}',
                                style: appStyle(14, FontWeight.w500, AppColors.cta)),
                          ),
                        ),
                      ]
                    : null,
              ),
              body: SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      children: [
                        _statusBar(track),
                        if (track.orderStatus != null &&
                            track.orderStatus != 'delivered' &&
                            track.orderStatus != 'cancelled')
                          WebTrackingStepper(status: track.orderStatus!),
                        Expanded(child: _buildMap(track)),
                        _infoBar(track),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _errorView(_WebTrack track) {
    final message = track.phase == _WebPhase.orderNotFound
        ? 'Order not found.'
        : 'Something went wrong.';
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.tr('live_tracking')),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(message,
                  style: appStyle(16, FontWeight.w600, const Color(0xFF111827)),
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _deliveredView() {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.tr('live_tracking')),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_outline, size: 48, color: Color(0xFF22C55E)),
              SizedBox(height: 16),
              Text('This order is no longer being tracked.',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _noActiveView() {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(context.t.tr('live_tracking')),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(40),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.info_outline, size: 48, color: AppColors.cta),
              const SizedBox(height: 16),
              Text(context.t.tr('no_active_tracking'),
                  style: appStyle(16, FontWeight.w600, const Color(0xFF111827)),
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(context.t.tr('tracking_will_appear'),
                  style: appStyle(14, FontWeight.w400, const Color(0xFF6B7280)),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusBar(_WebTrack track) {
    final Color dotColor;
    final String text;
    if (track.realtimeError) {
      dotColor = AppColors.error;
      text = context.t.tr('tracking_reconnecting');
    } else if (track.phase == _WebPhase.waiting) {
      dotColor = AppColors.pending;
      text = context.t.tr('waiting_for_driver');
    } else if (track.stale) {
      dotColor = AppColors.pending;
      text = context.t.tr('tracking_stale');
    } else {
      dotColor = AppColors.success;
      text = context.t.tr('tracking_live');
    }

    final driverLabel = track.driverName ??
        (_driverId != null ? context.t.tr('driver') : context.t.tr('no_driver_yet'));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text,
                    style: appStyle(14, FontWeight.w600, AppColors.textPrimary)),
                if (_driverId != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
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

  Widget _infoBar(_WebTrack track) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (track.routeUnavailable)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            color: const Color(0xFFFEF3C7),
            child: Text(context.t.tr('route_unavailable_note'),
                style: appStyle(12, FontWeight.w400, const Color(0xFF92400E))),
          ),
        if (track.distanceKm != null || track.driverPhone != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
            ),
            child: Row(
              children: [
                if (track.distanceKm != null) ...[
                  _infoChip(Icons.directions_car, '${track.distanceKm} km'),
                  const SizedBox(width: 16),
                  _infoChip(Icons.access_time, '${track.etaMin} min'),
                  const SizedBox(width: 8),
                ],
                const Spacer(),
                if (track.driverPhone != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ElevatedButton.icon(
                      onPressed: _callDriver,
                      icon: const Icon(Icons.call, size: 16),
                      label: Text(context.t.tr('call_driver')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                    ),
                  ),
                GestureDetector(
                  onTap: () {
                    _following = true;
                    _mapController?.animateTo(
                      _driverLat ?? 30.0444,
                      _driverLng ?? 31.2357,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(context.t.tr('recenter'),
                        style: const TextStyle(color: Colors.white, fontSize: 13)),
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
        Icon(icon, size: 16, color: const Color(0xFF6B7280)),
        const SizedBox(width: 4),
        Text(text, style: appStyle(14, FontWeight.w600, const Color(0xFF111827))),
      ],
    );
  }

  Widget _buildMap(_WebTrack track) {
    final lat = _driverLat ?? _destLat ?? 30.0444;
    final lng = _driverLng ?? _destLng ?? 31.2357;
    return Stack(
      children: [
        AdaptiveMap(
          initialLatitude: lat,
          initialLongitude: lng,
          initialZoom: _driverLat != null ? 13 : 12,
          markers: track.markers,
          polylines: track.polylines,
          showMyLocation: widget.driverId == null && widget.orderId == null,
          showMyLocationButton: true,
          onMapCreated: (ctrl) => _mapController = ctrl,
          onTap: (_) {
            if (_following) setState(() => _following = false);
          },
        ),
        if (!_following)
          Positioned(
            right: 12,
            bottom: 80,
            child: FloatingActionButton.small(
              heroTag: 'webFollowDriver',
              backgroundColor: AppColors.primary,
              onPressed: () {
                _following = true;
                _mapController?.animateTo(lat, lng);
              },
              child: const Icon(Icons.center_focus_strong, color: Colors.white),
            ),
          ),
        if (track.stale)
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                context.t.tr('tracking_stale'),
                style: appStyle(12, FontWeight.w400, const Color(0xFF92400E)),
              ),
            ),
          ),
      ],
    );
  }
}

/// Web parity stepper reflecting the driver-side order flow:
/// accepted -> picked_up -> in_transit -> delivered.
class WebTrackingStepper extends StatelessWidget {
  final String status;
  const WebTrackingStepper({super.key, required this.status});

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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          for (int i = 0; i < _labels.length; i++) ...[
            _stepDot(context, i < current, i == current, _labels[i]),
            if (i < _labels.length - 1)
              Expanded(
                child: Container(
                  height: 2,
                  color: i < current ? AppColors.success : AppColors.border,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _stepDot(BuildContext context, bool done, bool active, String labelKey) {
    final color = done
        ? AppColors.success
        : (active ? AppColors.primary : AppColors.textDisabled);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          child: done ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
        ),
        const SizedBox(height: 4),
        Text(context.t.tr(labelKey),
            style: appStyle(10, FontWeight.w500, color)),
      ],
    );
  }
}

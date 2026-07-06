import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ship_link/core/services/directions_service.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/user/presentation/screens/chat/order_chat_screen.dart';
import 'package:ship_link/core/widgets/adaptive_map.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ship_link/core/utils/sizer.dart';

class OrderRouteScreen extends StatefulWidget {
  final double destLat;
  final double destLng;
  final String? addressLabel;
  final String? address;
  final String orderId;
  final String userId;

  const OrderRouteScreen({
    super.key,
    required this.destLat,
    required this.destLng,
    this.addressLabel,
    this.address,
    required this.orderId,
    required this.userId,
  });

  @override
  State<OrderRouteScreen> createState() => _OrderRouteScreenState();
}

class _RouteState {
  final double? driverLat;
  final double? driverLng;
  final List<MapMarker> markers;
  final List<MapPolyline> polylines;
  final String? distanceText;
  final String? durationText;
  final bool loadingRoute;
  final bool routeFailed;

  const _RouteState({
    this.driverLat,
    this.driverLng,
    this.markers = const [],
    this.polylines = const [],
    this.distanceText,
    this.durationText,
    this.loadingRoute = true,
    this.routeFailed = false,
  });

  _RouteState copyWith({
    double? driverLat,
    double? driverLng,
    List<MapMarker>? markers,
    List<MapPolyline>? polylines,
    String? distanceText,
    String? durationText,
    bool? loadingRoute,
    bool? routeFailed,
  }) {
    return _RouteState(
      driverLat: driverLat ?? this.driverLat,
      driverLng: driverLng ?? this.driverLng,
      markers: markers ?? this.markers,
      polylines: polylines ?? this.polylines,
      distanceText: distanceText ?? this.distanceText,
      durationText: durationText ?? this.durationText,
      loadingRoute: loadingRoute ?? this.loadingRoute,
      routeFailed: routeFailed ?? this.routeFailed,
    );
  }
}

class _OrderRouteScreenState extends State<OrderRouteScreen> {
  final _state = ValueNotifier<_RouteState>(const _RouteState());

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    await _getDriverLocation();
    if (_state.value.driverLat != null && _state.value.driverLng != null) {
      await _fetchRoute();
    }
    _buildMarkers();
  }

  Future<void> _getDriverLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 8),
        ),
      );
      if (mounted) {
        _state.value = _state.value.copyWith(
          driverLat: pos.latitude,
          driverLng: pos.longitude,
        );
      }
    } catch (_) {}
  }

  Future<void> _fetchRoute() async {
    final dLat = _state.value.driverLat;
    final dLng = _state.value.driverLng;
    if (dLat == null || dLng == null) return;

    final service = DirectionsService();
    final route = await service.getRoute(
      originLat: dLat,
      originLng: dLng,
      destLat: widget.destLat,
      destLng: widget.destLng,
    );

    if (!mounted) return;

    if (route != null) {
      _state.value = _state.value.copyWith(
        polylines: [
          MapPolyline(
            id: 'route',
            points: route.polylinePoints,
            color: const Color(0xFF2563EB),
            width: 5,
          ),
        ],
        distanceText: route.distanceText,
        durationText: route.durationText,
        loadingRoute: false,
      );
    } else {
      final dist = Geolocator.distanceBetween(
            dLat, dLng, widget.destLat, widget.destLng,
          ) / 1000;
      _state.value = _state.value.copyWith(
        polylines: [
          MapPolyline(
            id: 'route',
            points: [
              MapLatLng(dLat, dLng),
              MapLatLng(widget.destLat, widget.destLng),
            ],
            color: const Color(0xFF2563EB),
            width: 4,
          ),
        ],
        distanceText: '${dist.toStringAsFixed(1)} ${context.t.tr('km')}',
        durationText: '${(dist / 0.5).round().clamp(1, 999)} ${context.t.tr('min')}',
        loadingRoute: false,
        routeFailed: true,
      );
    }
  }

  void _buildMarkers() {
    final s = _state.value;
    final markers = <MapMarker>[];
    if (s.driverLat != null && s.driverLng != null) {
      markers.add(MapMarker(
        id: 'driver',
        latitude: s.driverLat!,
        longitude: s.driverLng!,
        icon: buildDriverMarker(),
        label: context.t.tr('you'),
      ));
    }
    markers.add(MapMarker(
      id: 'destination',
      latitude: widget.destLat,
      longitude: widget.destLng,
      icon: buildDestinationMarker(),
      label: widget.addressLabel ?? context.t.tr('delivery'),
    ));
    _state.value = _state.value.copyWith(markers: markers);
  }

  Future<void> _openGoogleMaps() async {
    final dLat = _state.value.driverLat;
    final dLng = _state.value.driverLng;
    if (dLat == null || dLng == null) {
      final uri = Uri.parse('https://www.google.com/maps?q=${widget.destLat},${widget.destLng}');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return;
    }
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&origin=$dLat,$dLng&destination=${widget.destLat},${widget.destLng}&travelmode=driving',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<_RouteState>(
      valueListenable: _state,
      builder: (_, s, __) {
        final centerLat = s.driverLat ?? widget.destLat;
        final centerLng = s.driverLng ?? widget.destLng;
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(widget.addressLabel ?? '${context.t.tr('order_no')}${widget.orderId}'),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0.5,
          ),
          body: Column(
            children: [
              Expanded(
                child: AdaptiveMap(
                  initialLatitude: centerLat,
                  initialLongitude: centerLng,
                  initialZoom: 13,
                  markers: s.markers,
                  polylines: s.polylines,
                  showMyLocation: true,
                  showMyLocationButton: true,
                ),
              ),
              _buildInfoBar(s),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoBar(_RouteState s) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.address != null)
            Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Text(widget.address!,
                  style: appStyle(13, FontWeight.w400, const Color(0xFF6B7280)),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (s.loadingRoute)
                SizedBox(
                  width: 16.w, height: 16.h,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else ...[
                Flexible(
                  child: _infoChip(Icons.directions_car,
                      s.distanceText ?? '—', context.t.tr('distance')),
                ),
                SizedBox(width: 8.w),
                Flexible(
                  child: _infoChip(Icons.access_time,
                      s.durationText ?? '—', context.t.tr('est_time')),
                ),
              ],
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderChatScreen(
                          orderId: int.tryParse(widget.orderId) ?? 0,
                          driverId: Supabase.instance.client.auth.currentUser?.id ?? '',
                        ),
                      ),
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.chat, size: 16, color: Colors.white),
                          SizedBox(width: 4.w),
                          Text(context.t.tr('chat'),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  GestureDetector(
                    onTap: _openGoogleMaps,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.navigation, size: 16, color: Colors.white),
                          SizedBox(width: 4.w),
                          Text(context.t.tr('navigate'),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (s.routeFailed)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Text(context.t.tr('straight_line_estimate'),
                  style: appStyle(11, FontWeight.w400, const Color(0xFF9CA3AF))),
            ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: appStyle(11, FontWeight.w400, const Color(0xFF9CA3AF))),
        SizedBox(height: 2.h),
        Row(
          children: [
            Icon(icon, size: 16, color: const Color(0xFF6B7280)),
            SizedBox(width: 4.w),
            Text(text,
                style: appStyle(16, FontWeight.w700, const Color(0xFF111827))),
          ],
        ),
      ],
    );
  }
}
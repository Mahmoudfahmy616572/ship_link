import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ship_link/services/directions_service.dart';
import 'package:ship_link/views/shared/app_style.dart';
import 'package:ship_link/views/user/screens/chat/order_chat_screen.dart';
import 'package:ship_link/widgets/adaptive_map.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ship_link/utils/sizer.dart';

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

class _OrderRouteScreenState extends State<OrderRouteScreen> {
  double? _driverLat;
  double? _driverLng;
  List<MapMarker> _markers = [];
  List<MapPolyline> _polylines = [];
  String? _distanceText;
  String? _durationText;
  bool _loadingRoute = true;
  bool _routeFailed = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _getDriverLocation();
    if (_driverLat != null && _driverLng != null) {
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
        setState(() {
          _driverLat = pos.latitude;
          _driverLng = pos.longitude;
        });
      }
    } catch (_) {}
  }

  Future<void> _fetchRoute() async {
    final dLat = _driverLat;
    final dLng = _driverLng;
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
      setState(() {
        _polylines = [
          MapPolyline(
            id: 'route',
            points: route.polylinePoints,
            color: const Color(0xFF2563EB),
            width: 5,
          ),
        ];
        _distanceText = route.distanceText;
        _durationText = route.durationText;
        _loadingRoute = false;
      });
    } else {
      final dist = Geolocator.distanceBetween(
            dLat, dLng, widget.destLat, widget.destLng,
          ) / 1000;
      setState(() {
        _polylines = [
          MapPolyline(
            id: 'route',
            points: [
              MapLatLng(dLat, dLng),
              MapLatLng(widget.destLat, widget.destLng),
            ],
            color: const Color(0xFF2563EB),
            width: 4,
          ),
        ];
        _distanceText = '${dist.toStringAsFixed(1)} km';
        _durationText = '${(dist / 0.5).round().clamp(1, 999)} min';
        _loadingRoute = false;
        _routeFailed = true;
      });
    }
  }

  void _buildMarkers() {
    final markers = <MapMarker>[];
    if (_driverLat != null && _driverLng != null) {
      markers.add(MapMarker(
        id: 'driver',
        latitude: _driverLat!,
        longitude: _driverLng!,
        icon: buildDriverMarker(),
        label: 'You',
      ));
    }
    markers.add(MapMarker(
      id: 'destination',
      latitude: widget.destLat,
      longitude: widget.destLng,
      icon: buildDestinationMarker(),
      label: widget.addressLabel ?? 'Delivery',
    ));
    setState(() => _markers = markers);
  }

  Future<void> _openGoogleMaps() async {
    final dLat = _driverLat;
    final dLng = _driverLng;
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
    final centerLat = _driverLat ?? widget.destLat;
    final centerLng = _driverLng ?? widget.destLng;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.addressLabel ?? 'Order #${widget.orderId}'),
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
              markers: _markers,
              polylines: _polylines,
              showMyLocation: true,
              showMyLocationButton: true,
            ),
          ),
          _buildInfoBar(),
        ],
      ),
    );
  }

  Widget _buildInfoBar() {
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
          Row(
            children: [
              if (_loadingRoute)
                SizedBox(
                  width: 16.w, height: 16.h,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else ...[
                _infoChip(Icons.directions_car,
                    _distanceText ?? '—', 'Distance'),
                SizedBox(width: 16.w),
                _infoChip(Icons.access_time,
                    _durationText ?? '—', 'Est. time'),
              ],
              const Spacer(),
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
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chat, size: 18, color: Colors.white),
                      SizedBox(width: 6.w),
                      Text('Chat',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: _openGoogleMaps,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.navigation, size: 18, color: Colors.white),
                      SizedBox(width: 6.w),
                      Text('Navigate',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_routeFailed)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Text('Straight-line estimate — open Google Maps for precise routing',
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
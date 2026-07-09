import 'package:flutter/material.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/core/widgets/adaptive_map.dart';
import 'package:ship_link/core/services/supabase_service.dart';
import 'package:ship_link/core/utils/sizer.dart';

class TrackingWeb extends StatefulWidget {
  final String? driverId;
  final int? orderId;

  const TrackingWeb({super.key, this.driverId, this.orderId});
  static String routName = '/tracking';

  @override
  State<TrackingWeb> createState() => _TrackingWebState();
}

class _TrackingWebState extends State<TrackingWeb> {
  AdaptiveMapController? _mapController;
  final SupabaseService _supabase = SupabaseService();
  final ValueNotifier<List<MapMarker>> _markers = ValueNotifier([]);
  final ValueNotifier<bool> _loading = ValueNotifier(true);

  @override
  void initState() {
    super.initState();
    _setupTracking();
  }

  void _setupTracking() {
    if (widget.driverId != null) {
      _supabase.getDriverLocation(widget.driverId!).listen((data) {
        if (data.isNotEmpty && mounted) {
          final lat = (data['latitude'] as num).toDouble();
          final lng = (data['longitude'] as num).toDouble();
          _markers.value = [
            MapMarker(
              id: 'driver',
              latitude: lat,
              longitude: lng,
              icon: buildDriverMarker(),
              label: context.t.tr('driver_location'),
            ),
          ];
          _mapController?.animateTo(lat, lng);
          if (_loading.value) _loading.value = false;
        }
      });
    } else {
      _loading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  padding: EdgeInsets.only(right: 8),
                  child: Center(
                    child: Text('#${widget.orderId}',
                        style: appStyle(14, FontWeight.w500, AppColors.cta)),
                  ),
                ),
              ]
            : null,
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: _loading,
        builder: (_, loading, __) {
          if (loading && widget.driverId != null) {
            return const Center(child: CircularProgressIndicator());
          }
          return Stack(
            children: [
              ValueListenableBuilder<List<MapMarker>>(
                valueListenable: _markers,
                builder: (_, markers, __) {
                  return AdaptiveMap(
                    initialLatitude: 30.0444,
                    initialLongitude: 31.2357,
                    initialZoom: 12,
                    markers: markers,
                    showMyLocation: widget.driverId == null,
                    showMyLocationButton: true,
                    onMapCreated: (ctrl) => _mapController = ctrl,
                  );
                },
              ),
              if (widget.driverId == null)
                Center(
                  child: Container(
                    margin: EdgeInsets.all(40),
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.info_outline, size: 48, color: AppColors.cta),
                        SizedBox(height: 16),
                        Text(context.t.tr('no_active_tracking'),
                            style: appStyle(16, FontWeight.w600, const Color(0xFF111827)),
                            textAlign: TextAlign.center),
                        SizedBox(height: 8),
                        Text(context.t.tr('tracking_will_appear'),
                            style: appStyle(14, FontWeight.w400, const Color(0xFF6B7280)),
                            textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

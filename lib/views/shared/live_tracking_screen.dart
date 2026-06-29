import 'package:flutter/material.dart';
import 'package:ship_link/localization.dart';
import 'package:ship_link/services/supabase_service.dart';
import 'package:ship_link/widgets/adaptive_map.dart';

class LiveTrackingScreen extends StatefulWidget {
  final String? driverId;

  const LiveTrackingScreen({super.key, this.driverId});
  static String routName = '/liveTracking';

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  AdaptiveMapController? _mapController;
  final SupabaseService _supabase = SupabaseService();
  List<MapMarker> _markers = [];

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
          setState(() {
            _markers = [
              MapMarker(
                id: 'driver',
                latitude: lat,
                longitude: lng,
                icon: buildDriverMarker(),
                label: context.t.tr('driver_location'),
              ),
            ];
          });
          _mapController?.animateTo(lat, lng);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.tr('live_tracking')),
        centerTitle: true,
      ),
      body: AdaptiveMap(
        initialLatitude: 30.0444,
        initialLongitude: 31.2357,
        initialZoom: 12,
        markers: _markers,
        showMyLocation: widget.driverId == null,
        showMyLocationButton: true,
        onMapCreated: (ctrl) => _mapController = ctrl,
      ),
    );
  }
}

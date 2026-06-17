import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ship_link/config.dart';
import 'package:ship_link/services/supabase_service.dart';

class LiveTrackingScreen extends StatefulWidget {
  final String? driverId;

  const LiveTrackingScreen({super.key, this.driverId});
  static String routName = '/liveTracking';

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final SupabaseService _supabase = SupabaseService();

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
            _markers.clear();
            _markers.add(
              Marker(
                markerId: const MarkerId('driver'),
                position: LatLng(lat, lng),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueBlue),
                infoWindow:
                    const InfoWindow(title: 'Driver Location'),
              ),
            );
          });
          _mapController?.animateCamera(
            CameraUpdate.newLatLng(LatLng(lat, lng)),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Tracking'),
        centerTitle: true,
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(30.0444, 31.2357),
          zoom: 12,
        ),
        markers: _markers,
        myLocationEnabled: widget.driverId == null,
        myLocationButtonEnabled: true,
        onMapCreated: (controller) {
          _mapController = controller;
        },
      ),
    );
  }
}

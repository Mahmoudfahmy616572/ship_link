import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as fl;
import 'package:google_maps_flutter/google_maps_flutter.dart' as gm;
import 'package:geolocator/geolocator.dart';
import 'package:ship_link/core/maps/renderer/maptiler_config.dart';
import 'package:ship_link/core/services/map_service.dart';

class MapMarker {
  final String id;
  final double latitude;
  final double longitude;
  final Widget icon;
  final String? label;

  const MapMarker({
    required this.id,
    required this.latitude,
    required this.longitude,
    this.icon = const Icon(Icons.location_on, color: Colors.blue, size: 40),
    this.label,
  });
}

class MapLatLng {
  final double latitude;
  final double longitude;
  const MapLatLng(this.latitude, this.longitude);
}

class MapPolyline {
  final String id;
  final List<MapLatLng> points;
  final Color color;
  final double width;
  final Color? casingColor;
  final double casingWidth;

  const MapPolyline({
    required this.id,
    required this.points,
    this.color = Colors.blue,
    this.width = 3,
    this.casingColor,
    this.casingWidth = 0,
  });
}

class AdaptiveMapController {
  final dynamic _controller;
  final bool _isGoogle;

  AdaptiveMapController(this._controller, this._isGoogle);

  Future<void> animateTo(double lat, double lng, {double? zoom}) async {
    if (_isGoogle) {
      final c = _controller as gm.GoogleMapController;
      if (zoom != null) {
        await c.animateCamera(gm.CameraUpdate.newLatLngZoom(gm.LatLng(lat, lng), zoom));
      } else {
        await c.animateCamera(gm.CameraUpdate.newLatLng(gm.LatLng(lat, lng)));
      }
    } else {
      final c = _controller as MapController;
      c.move(fl.LatLng(lat, lng), zoom ?? 12);
    }
  }
}

class AdaptiveMap extends StatefulWidget {
  final double initialLatitude;
  final double initialLongitude;
  final double initialZoom;
  final bool showMyLocation;
  final bool showMyLocationButton;
  final ValueChanged<MapMarker>? onMarkerTapped;
  final ValueChanged<MapLatLng>? onTap;
  final List<MapMarker> markers;
  final List<MapPolyline> polylines;
  final void Function(AdaptiveMapController)? onMapCreated;

  const AdaptiveMap({
    super.key,
    required this.initialLatitude,
    required this.initialLongitude,
    this.initialZoom = 12,
    this.showMyLocation = false,
    this.showMyLocationButton = false,
    this.onMarkerTapped,
    this.onTap,
    this.markers = const [],
    this.polylines = const [],
    this.onMapCreated,
  });

  @override
  State<AdaptiveMap> createState() => _AdaptiveMapState();
}

class _AdaptiveMapState extends State<AdaptiveMap> {
  final ValueNotifier<bool?> _useGoogle = ValueNotifier(null);
  Timer? _retryTimer;
  final MapController _flutterMapCtrl = MapController();
  final ValueNotifier<Position?> _userPosition = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    _checkAvailability();
    _fetchUserPosition();
  }

  Future<void> _fetchUserPosition() async {
    if (!widget.showMyLocation) return;
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      _userPosition.value = pos;
    } catch (_) {}
  }

  Future<void> _checkAvailability() async {
    final provider = await MapService.activeProvider;
    _useGoogle.value = provider == MapProviderType.google;
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_useGoogle.value == null) {
      return _buildFlutterMap();
    }
    if (_useGoogle.value!) {
      return _buildGoogleMap();
    }
    return _buildFlutterMap();
  }

  Widget _buildGoogleMap() {
    return gm.GoogleMap(
      initialCameraPosition: gm.CameraPosition(
        target: gm.LatLng(widget.initialLatitude, widget.initialLongitude),
        zoom: widget.initialZoom,
      ),
      markers: _googleMarkers(),
      polylines: _googlePolylineSet(),
      myLocationEnabled: widget.showMyLocation,
      myLocationButtonEnabled: widget.showMyLocationButton,
      onTap: (latLng) => widget.onTap?.call(MapLatLng(latLng.latitude, latLng.longitude)),
      onMapCreated: (controller) {
        widget.onMapCreated?.call(AdaptiveMapController(controller, true));
      },
    );
  }

  Set<gm.Polyline> _googlePolylineSet() {
    final set = <gm.Polyline>{};
    for (final p in widget.polylines) {
      if (p.casingColor != null && p.casingWidth > 0) {
        set.add(gm.Polyline(
          polylineId: gm.PolylineId('${p.id}_casing'),
          points: p.points.map((pt) => gm.LatLng(pt.latitude, pt.longitude)).toList(),
          color: p.casingColor!,
          width: p.casingWidth.toInt(),
          zIndex: 1,
        ));
      }
      set.add(gm.Polyline(
        polylineId: gm.PolylineId(p.id),
        points: p.points.map((pt) => gm.LatLng(pt.latitude, pt.longitude)).toList(),
        color: p.color,
        width: p.width.toInt(),
        zIndex: 2,
      ));
    }
    return set;
  }

  Set<gm.Marker> _googleMarkers() {
    return widget.markers.map((m) {
      return gm.Marker(
        markerId: gm.MarkerId(m.id),
        position: gm.LatLng(m.latitude, m.longitude),
        infoWindow: gm.InfoWindow(title: m.label ?? ''),
        onTap: () => widget.onMarkerTapped?.call(m),
      );
    }).toSet();
  }

  Widget _buildFlutterMap() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final markers = _flutterMarkers().toList();
    if (widget.showMyLocation && _userPosition.value != null) {
      markers.add(
        Marker(
          point: fl.LatLng(_userPosition.value!.latitude, _userPosition.value!.longitude),
          alignment: Alignment.center,
          child: Container(
            width: 18.w, height: 18.h,
            decoration: const BoxDecoration(
              color: Color(0xFF4285F4),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
            ),
          ),
        ),
      );
    }
    return Stack(
      children: [
        FlutterMap(
          mapController: _flutterMapCtrl,
          options: MapOptions(
            initialCenter: fl.LatLng(widget.initialLatitude, widget.initialLongitude),
            initialZoom: widget.initialZoom,
            onTap: (tapPos, latLng) => widget.onTap?.call(MapLatLng(latLng.latitude, latLng.longitude)),
            onMapReady: () {
              widget.onMapCreated?.call(AdaptiveMapController(_flutterMapCtrl, false));
            },
          ),
          children: [
            TileLayer(
              urlTemplate: MapTilerConfig.activeTileTemplate(dark: isDark),
              userAgentPackageName: 'com.ship_link',
            ),
            PolylineLayer(polylines: _flutterPolylines()),
            MarkerLayer(markers: markers),
            RichAttributionWidget(
              attributions: [
                TextSourceAttribution(MapTilerConfig.activeAttribution),
              ],
            ),
          ],
        ),
        if (widget.showMyLocationButton)
          Positioned(
            right: 12.w, bottom: 12.h,
            child: FloatingActionButton.small(
              heroTag: 'myLocationFm',
              onPressed: () async {
                try {
                  final pos = await Geolocator.getCurrentPosition(
                    locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
                  );
                  _flutterMapCtrl.move(fl.LatLng(pos.latitude, pos.longitude), widget.initialZoom);
                } catch (_) {}
              },
              child: const Icon(Icons.my_location, color: Color(0xFF4285F4)),
            ),
          ),
      ],
    );
  }

  List<Polyline> _flutterPolylines() {
    final list = <Polyline>[];
    for (final p in widget.polylines) {
      if (p.casingColor != null && p.casingWidth > 0) {
        list.add(Polyline(
          points: p.points.map((pt) => fl.LatLng(pt.latitude, pt.longitude)).toList(),
          color: p.casingColor!,
          strokeWidth: p.casingWidth,
        ));
      }
      list.add(Polyline(
        points: p.points.map((pt) => fl.LatLng(pt.latitude, pt.longitude)).toList(),
        color: p.color,
        strokeWidth: p.width,
      ));
    }
    return list;
  }

  List<Marker> _flutterMarkers() {
    return widget.markers.map((m) {
      return Marker(
        point: fl.LatLng(m.latitude, m.longitude),
        width: 160.w,
        height: 80.h,
        alignment: Alignment.bottomCenter,
        child: ClipRect(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 44.w, height: 44.h, child: Center(child: m.icon)),
                if (m.label != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                    ),
                    child: Text(m.label!, style: TextStyle(fontSize: 10.sp),
                        overflow: TextOverflow.ellipsis, maxLines: 1),
                  ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }
}

Widget buildDriverMarker({Color color = AppColors.driverMarker, double size = 40}) {
  return Container(
    width: size.w,
    height: size.h,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: 3),
      boxShadow: const [
        BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
      ],
    ),
    child: const Icon(Icons.directions_car, color: Colors.white, size: 22),
  );
}

Widget buildDestinationMarker({Color color = AppColors.deliveredMarker, double size = 36}) {
  return Container(
    width: size.w,
    height: size.h,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: 3.w),
      boxShadow: const [
        BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
      ],
    ),
    child: const Icon(Icons.flag, color: Colors.white, size: 20),
  );
}

Widget buildOriginMarker({Color color = AppColors.customerMarker, double size = 34}) {
  return Container(
    width: size.w,
    height: size.h,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: 3.w),
      boxShadow: const [
        BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
      ],
    ),
    child: const Icon(Icons.person_pin, color: Colors.white, size: 20),
  );
}

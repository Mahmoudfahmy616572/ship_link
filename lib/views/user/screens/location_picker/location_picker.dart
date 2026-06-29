import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ship_link/cubits/auth/cubit/auth_cubit.dart';
import 'package:ship_link/cubits/auth/cubit/auth_stat.dart';
import 'package:ship_link/localization.dart';
import 'package:ship_link/views/user/screens/MainScreen/main_screen.dart';
import 'package:ship_link/constant/colors.dart';
import 'package:ship_link/views/shared/app_style.dart';
import 'package:ship_link/utils/sizer.dart';
import 'package:ship_link/widgets/adaptive_map.dart';
import 'package:ship_link/services/geocoding_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

class LocationPicker extends StatefulWidget {
  final bool isAddressPicker;
  const LocationPicker({super.key, this.isAddressPicker = false});
  static String routName = '/locationPicker';
  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  MapLatLng? _selectedLocation;
  final _mapController = Completer<AdaptiveMapController>();
  List<MapMarker> _markers = [];
  bool _locationGranted = false;
  final double _initialLat = 30.0444;
  final double _initialLng = 31.2357;
  final double _initialZoom = 12;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initLocation());
  }

  Future<void> _initLocation() async {
    final status = await Permission.location.request();
    if (!mounted) return;
    final granted = status.isGranted;
    setState(() => _locationGranted = granted);
    if (granted) {
      try {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
        );
        if (!mounted) return;
        final lat = pos.latitude;
        final lng = pos.longitude;
        setState(() {
          _selectedLocation = MapLatLng(lat, lng);
          _markers = [
            MapMarker(
              id: 'selected',
              latitude: lat,
              longitude: lng,
              icon: const Icon(Icons.location_on, color: Colors.blue, size: 40),
            ),
          ];
        });
        final controller = _mapController.isCompleted ? await _mapController.future : null;
        await controller?.animateTo(lat, lng, zoom: 15);
      } catch (_) {}
    }
  }

  void _onMapTap(MapLatLng point) {
    setState(() {
      _selectedLocation = point;
      _markers = [
        MapMarker(
          id: 'selected',
          latitude: point.latitude,
          longitude: point.longitude,
          icon: const Icon(Icons.location_on, color: Colors.blue, size: 40),
        ),
      ];
    });
  }

  void _save() async {
    if (_selectedLocation == null) return;

    final lat = _selectedLocation!.latitude;
    final lng = _selectedLocation!.longitude;

    // Try reverse geocoding to get address details
    final addr = await GeocodingService.reverseGeocode(lat, lng);

    if (widget.isAddressPicker) {
      if (!mounted) return;
      Navigator.pop(context, {
        'latitude': lat,
        'longitude': lng,
        'governorate': addr?.governorate ?? '',
        'city': addr?.city ?? '',
        'street': addr?.road ?? '',
        'full_address': addr?.fullAddress ?? '$lat, $lng',
      });
      return;
    }

    if (!mounted) return;
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      // Save to user_addresses as the default address
      await Supabase.instance.client.from('user_addresses').insert({
        'user_id': user.id,
        'label': 'Home',
        'city': addr?.city ?? addr?.governorate ?? '',
        'street': addr?.road ?? '',
        'full_address': addr?.fullAddress ?? '$lat, $lng',
        'latitude': lat,
        'longitude': lng,
        'is_default': true,
      });
    }

    final cubit = AuthCubit.get(context);
    await cubit.completeRegistration(
      lat: _selectedLocation!.latitude,
      lng: _selectedLocation!.longitude,
      address: addr?.fullAddress,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Sizer.init(context);

    if (widget.isAddressPicker) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(context.t.tr('pick_location'),
              style: appStyle(20, FontWeight.w600, AppColors.textPrimary)),
          backgroundColor: AppColors.background,
          elevation: 0,
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Text(
                context.t.tr('tap_map_to_set'),
                style: appStyle(14, FontWeight.w400, AppColors.textSecondary),
              ),
            ),
            Expanded(
              child: AdaptiveMap(
                initialLatitude: _initialLat,
                initialLongitude: _initialLng,
                initialZoom: _initialZoom,
                onTap: _onMapTap,
                markers: _markers,
                showMyLocation: _locationGranted,
                showMyLocationButton: _locationGranted,
                onMapCreated: (ctrl) {
                  if (!_mapController.isCompleted) _mapController.complete(ctrl);
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: _selectedLocation != null ? _save : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cta,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(context.t.tr('confirm_location'),
                      style: appStyle(16, FontWeight.w600, Colors.white)),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(context.t.tr('set_your_location'))),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is SuccessState && mounted) {
            Navigator.pushNamedAndRemoveUntil(
                context, MainScreen.routName, (route) => false);
          } else if (state is ErrorState && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 8.h, bottom: 8.h),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    context.t.tr('tap_map_to_set'),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              Expanded(
                child: AdaptiveMap(
                  initialLatitude: _initialLat,
                  initialLongitude: _initialLng,
                  initialZoom: _initialZoom,
                  onTap: _onMapTap,
                  markers: _markers,
                  showMyLocation: _locationGranted,
                  showMyLocationButton: _locationGranted,
                  onMapCreated: (ctrl) {
                    if (!_mapController.isCompleted) _mapController.complete(ctrl);
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.w),
                child: SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: _selectedLocation != null ? _save : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF242424),
                      foregroundColor: Colors.white,
                    ),
                    child: state is LoadingState
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(context.t.tr('save_and_continue'),
                            style: TextStyle(fontSize: 18.sp)),
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

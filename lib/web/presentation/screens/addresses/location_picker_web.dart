import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart' as latlng;
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/maps/maps.dart';
import 'package:ship_link/core/maps/renderer/maptiler_config.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/widgets/app_style.dart';

class LocationPickerWeb extends StatefulWidget {
  const LocationPickerWeb({super.key});

  @override
  State<LocationPickerWeb> createState() => _LocationPickerWebState();
}

class _LocationPickerWebState extends State<LocationPickerWeb> {
  final _mapCtrl = MapController();
  final _searchCtrl = TextEditingController();
  latlng.LatLng? _selected;
  bool _geocoding = false;
  bool _searching = false;
  List<GeocodingResult> _searchResults = const [];
  String _addressHint = '';

  static const _defaultCenter = latlng.LatLng(30.0444, 31.2357);

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _reverseGeocode(double lat, double lng) async {
    setState(() => _geocoding = true);
    try {
      final uri = Uri.parse('https://nominatim.openstreetmap.org/reverse'
          '?format=json&lat=$lat&lon=$lng&addressdetails=1');
      final res = await http.get(uri, headers: {'User-Agent': 'ShipLink/1.0'});
      if (res.statusCode == 200 && mounted) {
        final json = jsonDecode(res.body) as Map<String, dynamic>;
        setState(() => _addressHint = json['display_name'] as String? ?? '');
      }
    } catch (_) {}
    if (mounted) setState(() => _geocoding = false);
  }

  void _onTap(latlng.LatLng pos) {
    setState(() {
      _selected = pos;
      _searchResults = const [];
      _addressHint = '';
    });
    _reverseGeocode(pos.latitude, pos.longitude);
  }

  Future<void> _runSearch() async {
    final q = _searchCtrl.text.trim();
    if (q.length < 3) {
      setState(() => _searchResults = const []);
      return;
    }
    setState(() => _searching = true);
    try {
      final results = await geocodingService.search(q, countryCode: 'EG', limit: 5);
      if (mounted) setState(() => _searchResults = results);
    } catch (_) {
      if (mounted) setState(() => _searchResults = const []);
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  void _pickSearchResult(GeocodingResult r) {
    final pos = latlng.LatLng(r.coordinate.latitude, r.coordinate.longitude);
    setState(() {
      _selected = pos;
      _searchResults = const [];
      _addressHint = r.formattedAddress;
    });
    _mapCtrl.move(pos, 14);
  }

  void _confirm() async {
    if (_selected == null) return;

    String city = '';
    String street = '';
    String fullAddress = _addressHint;

    try {
      final uri = Uri.parse('https://nominatim.openstreetmap.org/reverse'
          '?format=json&lat=${_selected!.latitude}&lon=${_selected!.longitude}&addressdetails=1');
      final res = await http.get(uri, headers: {'User-Agent': 'ShipLink/1.0'});
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body) as Map<String, dynamic>;
        final address = json['address'] as Map<String, dynamic>? ?? {};
        city = address['city'] as String? ??
            address['town'] as String? ??
            address['village'] as String? ?? '';
        street = address['road'] as String? ??
            address['street'] as String? ?? '';
        if (fullAddress.isEmpty) {
          final governorate = address['state'] as String? ?? '';
          final parts = <String>[
            if (governorate.isNotEmpty) governorate,
            if (city.isNotEmpty) city,
            if (street.isNotEmpty) street,
          ];
          fullAddress = parts.isNotEmpty ? parts.join(', ') : json['display_name'] as String? ?? '';
        }
      }
    } catch (_) {}

    if (mounted) {
      Navigator.pop(context, {
        'latitude': _selected!.latitude,
        'longitude': _selected!.longitude,
        'city': city,
        'street': street,
        'full_address': fullAddress,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.tr('pick_location')),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0.5,
        actions: [
          TextButton(
            onPressed: _selected != null ? _confirm : null,
            child: Text(context.t.tr('confirm'),
                style: appStyle(16, FontWeight.w600, _selected != null ? AppColors.primary : const Color(0xFF9CA3AF))),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapCtrl,
            options: MapOptions(
              initialCenter: _defaultCenter,
              initialZoom: 12,
              onTap: (_, pos) => _onTap(pos),
            ),
            children: [
              TileLayer(
                urlTemplate: MapTilerConfig.activeTileTemplate(
                  dark: Theme.of(context).brightness == Brightness.dark,
                ),
                userAgentPackageName: 'com.shiplink.app',
              ),
              if (_selected != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selected!,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                    ),
                  ],
                ),
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(MapTilerConfig.activeAttribution),
                ],
              ),
            ],
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 10)
                    ],
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (_) => _runSearch(),
                    decoration: const InputDecoration(
                      hintText: 'ابحث عن عنوان...',
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                if (_searching)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ..._searchResults.map(
                  (r) => GestureDetector(
                    onTap: () => _pickSearchResult(r),
                    child: Container(
                      margin: const EdgeInsets.only(top: 6),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 6)
                        ],
                      ),
                      child: Text(
                        r.formattedAddress,
                        style: appStyle(13, FontWeight.w500,
                            const Color(0xFF111827)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(context.t.tr('tap_map_to_select'),
                  style: appStyle(14, FontWeight.w500, Colors.black54)),
            ),
          ),
          if (_geocoding)
            Positioned(
              left: 16, right: 16, bottom: 16,
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
                ),
                child: Row(
                  children: [
                    SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                    SizedBox(width: 12),
                    Text(context.t.tr('fetching_address'),
                        style: appStyle(13, FontWeight.w400, const Color(0xFF6B7280))),
                  ],
                ),
              ),
            ),
          if (_addressHint.isNotEmpty && !_geocoding)
            Positioned(
              left: 16, right: 16, bottom: 16,
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: AppColors.cta, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(_addressHint,
                          style: appStyle(13, FontWeight.w400, const Color(0xFF111827)),
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

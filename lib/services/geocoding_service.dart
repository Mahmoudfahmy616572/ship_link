import 'dart:convert';
import 'package:http/http.dart' as http;

class AddressResult {
  final String fullAddress;
  final String governorate;
  final String city;
  final String road;
  final double lat;
  final double lng;

  AddressResult({
    required this.fullAddress,
    required this.governorate,
    required this.city,
    required this.road,
    required this.lat,
    required this.lng,
  });
}

class GeocodingService {
  static Future<AddressResult?> reverseGeocode(double lat, double lng) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?format=json&lat=$lat&lon=$lng&addressdetails=1',
      );
      final res = await http.get(uri, headers: {
        'User-Agent': 'ShipLink/1.0',
        'Accept-Language': 'ar', 
      });
      if (res.statusCode != 200) return null;
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final address = json['address'] as Map<String, dynamic>? ?? {};
      final displayName = json['display_name'] as String? ?? '';

      // Egyptian admin hierarchy: state=governorate, city, road
      final governorate = address['state'] as String? ??
          address['region'] as String? ??
          '';
      final city = address['city'] as String? ??
          address['town'] as String? ??
          address['village'] as String? ??
          address['county'] as String? ??
          '';
      final road = address['road'] as String? ??
          address['street'] as String? ??
          '';

      // Build a clean Egyptian address: Governorate, City, Street
      final parts = <String>[
        if (governorate.isNotEmpty) governorate,
        if (city.isNotEmpty) city,
        if (road.isNotEmpty) road,
      ];
      final cleanAddress = parts.isNotEmpty ? parts.join(', ') : displayName;

      return AddressResult(
        fullAddress: cleanAddress,
        governorate: governorate,
        city: city,
        road: road,
        lat: lat,
        lng: lng,
      );
    } catch (_) {
      return null;
    }
  }
}

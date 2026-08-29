import 'package:flutter_test/flutter_test.dart';
import 'package:ship_link/core/maps/adapters/map_coordinate_adapter.dart';
import 'package:ship_link/core/maps/interfaces/geocoding_provider.dart';
import 'package:ship_link/core/maps/interfaces/route_service.dart';
import 'package:ship_link/core/maps/models/map_coordinate.dart';
import 'package:ship_link/core/maps/models/route_result.dart';
import 'package:ship_link/core/maps/providers/google_directions_route_provider.dart';
import 'package:ship_link/core/maps/providers/nominatim_geocoding_provider.dart';
import 'package:ship_link/core/services/map_service.dart';
import 'package:ship_link/core/widgets/adaptive_map.dart';

void main() {
  group('MapCoordinate', () {
    test('accepts valid coordinates', () {
      const c = MapCoordinate(30.0444, 31.2357);
      expect(c.isValid, isTrue);
    });

    test('rejects out-of-range latitude', () {
      expect(const MapCoordinate(91, 31).isValid, isFalse);
    });

    test('rejects out-of-range longitude', () {
      expect(const MapCoordinate(30, 181).isValid, isFalse);
    });

    test('equality is value-based', () {
      expect(const MapCoordinate(30, 31), equals(const MapCoordinate(30, 31)));
      expect(const MapCoordinate(30, 31).hashCode,
          equals(const MapCoordinate(30, 31).hashCode));
    });
  });

  group('MapCoordinate <-> MapLatLng adapter', () {
    test('converts to renderer-neutral MapLatLng', () {
      const c = MapCoordinate(30.0, 31.0);
      final m = c.toMapLatLng();
      expect(m, isA<MapLatLng>());
      expect(m.latitude, 30.0);
      expect(m.longitude, 31.0);
    });

    test('round-trips back to MapCoordinate', () {
      const c = MapCoordinate(30.0, 31.0);
      final back = c.toMapLatLng().toCoordinate();
      expect(back, equals(c));
    });
  });

  group('RouteResult', () {
    test('defaults to empty/zero', () {
      const r = RouteResult();
      expect(r.polylinePoints, isEmpty);
      expect(r.distanceMeters, 0);
      expect(r.durationSeconds, 0);
      expect(r.isApproximate, isFalse);
    });

    test('carries neutral polyline points + real metrics', () {
      final r = RouteResult(
        polylinePoints: [const MapCoordinate(30, 31)],
        distanceMeters: 5200,
        durationSeconds: 900,
        distanceText: '5.2 km',
        durationText: '15 mins',
        provider: 'google_directions',
      );
      expect(r.polylinePoints.first, isA<MapCoordinate>());
      expect(r.distanceMeters, 5200);
      expect(r.durationSeconds, 900);
    });
  });

  group('MapService.selectProvider (pure, testable rule)', () {
    test('FlutterMap + MapTiler is primary even on Android GMS', () {
      MapService.enableGoogleRenderer = false;
      expect(
        MapService.selectProvider(googleAvailable: true, isWeb: false),
        MapProviderType.flutterMap,
      );
    });

    test('opt-in Google renderer still works on Android GMS', () {
      MapService.enableGoogleRenderer = true;
      expect(
        MapService.selectProvider(googleAvailable: true, isWeb: false),
        MapProviderType.google,
      );
      MapService.enableGoogleRenderer = false;
    });

    test('web always uses flutterMap regardless of GMS', () {
      expect(
        MapService.selectProvider(googleAvailable: true, isWeb: true),
        MapProviderType.flutterMap,
      );
    });
  });

  group('Provider abstraction', () {
    test('GoogleDirectionsRouteProvider implements RouteService', () {
      expect(GoogleDirectionsRouteProvider(), isA<RouteService>());
    });

    test('NominatimGeocodingProvider implements GeocodingProvider', () {
      expect(
        NominatimGeocodingProvider(),
        isA<GeocodingProvider>(),
      );
    });

    test('feature layer can consume RouteResult via the interface', () async {
      final service = _FakeRouteService();
      final route = await service.getRoute(
        origin: const MapCoordinate(30, 31),
        destination: const MapCoordinate(30.1, 31.1),
      );
      expect(route, isA<RouteResult>());
      expect(route!.polylinePoints.first, isA<MapCoordinate>());
    });
  });
}

class _FakeRouteService implements RouteService {
  @override
  Future<RouteResult?> getRoute({
    required MapCoordinate origin,
    required MapCoordinate destination,
  }) async {
    return RouteResult(
      polylinePoints: [origin, destination],
      distanceMeters: 1000,
      durationSeconds: 120,
    );
  }
}

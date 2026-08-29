import 'package:flutter_test/flutter_test.dart';
import 'package:ship_link/core/models/driver_location.dart';
import 'package:ship_link/core/maps/providers/google_directions_route_provider.dart';
import 'package:ship_link/user/presentation/screens/tracking/driver_tracking_screen.dart';

void main() {
  group('DriverLocation parsing & validation', () {
    test('parses a valid row', () {
      final loc = DriverLocation.tryParse({
        'driver_id': 'drv-1',
        'latitude': 30.0,
        'longitude': 31.0,
        'status': 'online',
        'updated_at': DateTime.now().toIso8601String(),
      });
      expect(loc, isNotNull);
      expect(loc!.driverId, 'drv-1');
      expect(loc.latitude, 30.0);
      expect(loc.longitude, 31.0);
      expect(loc.isStale, isFalse);
    });

    test('rejects invalid latitude', () {
      final loc = DriverLocation.tryParse({
        'driver_id': 'drv-1',
        'latitude': 999.0,
        'longitude': 31.0,
        'updated_at': DateTime.now().toIso8601String(),
      });
      expect(loc, isNull);
    });

    test('rejects invalid longitude', () {
      final loc = DriverLocation.tryParse({
        'driver_id': 'drv-1',
        'latitude': 30.0,
        'longitude': 999.0,
        'updated_at': DateTime.now().toIso8601String(),
      });
      expect(loc, isNull);
    });

    test('rejects missing coordinates', () {
      final loc = DriverLocation.tryParse({
        'driver_id': 'drv-1',
        'updated_at': DateTime.now().toIso8601String(),
      });
      expect(loc, isNull);
    });

    test('rejects missing driverId', () {
      final loc = DriverLocation.tryParse({
        'latitude': 30.0,
        'longitude': 31.0,
        'updated_at': DateTime.now().toIso8601String(),
      });
      expect(loc, isNull);
    });

    test('fallback driverId is used when present', () {
      final loc = DriverLocation.tryParse({
        'latitude': 30.0,
        'longitude': 31.0,
        'updated_at': DateTime.now().toIso8601String(),
      }, fallbackDriverId: 'drv-9');
      expect(loc, isNotNull);
      expect(loc!.driverId, 'drv-9');
    });

    test('isValidCoordinate enforces WGS84 bounds', () {
      expect(DriverLocation.isValidCoordinate(0, 0), isTrue);
      expect(DriverLocation.isValidCoordinate(-90, -180), isTrue);
      expect(DriverLocation.isValidCoordinate(90, 180), isTrue);
      expect(DriverLocation.isValidCoordinate(-91, 0), isFalse);
      expect(DriverLocation.isValidCoordinate(0, 181), isFalse);
    });

    test('isStale reflects updated_at', () {
      final fresh = DriverLocation(
        driverId: 'd',
        latitude: 1,
        longitude: 1,
        updatedAt: DateTime.now().subtract(const Duration(seconds: 10)),
      );
      expect(fresh.isStale, isFalse);

      final old = DriverLocation(
        driverId: 'd',
        latitude: 1,
        longitude: 1,
        updatedAt: DateTime.now().subtract(const Duration(seconds: 61)),
      );
      expect(old.isStale, isTrue);

      final unknown = DriverLocation(
        driverId: 'd',
        latitude: 1,
        longitude: 1,
      );
      expect(unknown.isStale, isTrue);
    });
  });

  group('parseTrackingOrderId', () {
    test('returns null for null/empty', () {
      expect(parseTrackingOrderId(null), isNull);
      expect(parseTrackingOrderId(''), isNull);
      expect(parseTrackingOrderId('   '), isNull);
    });

    test('returns trimmed string and int', () {
      expect(parseTrackingOrderId('123'), '123');
      expect(parseTrackingOrderId(123), '123');
      expect(parseTrackingOrderId(123.0), '123');
    });
  });

  group('GoogleDirectionsRouteProvider.decodePolyline', () {
    test('decodes a known encoded polyline', () {
      // Google classic example: single point (38.5, -120.2)
      final points = GoogleDirectionsRouteProvider.decodePolyline('_p~iF~ps|U');
      expect(points.length, 1);
      expect(points.first.latitude, closeTo(38.5, 1e-6));
      expect(points.first.longitude, closeTo(-120.2, 1e-6));
    });

    test('decodes a multi-point polyline', () {
      // Google classic 3-point example.
      final points = GoogleDirectionsRouteProvider.decodePolyline(
          '_p~iF~ps|U_ulLnnqC_mqNvxq`@');
      expect(points.length, 3);
    });
  });
}

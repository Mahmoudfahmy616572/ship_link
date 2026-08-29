import 'package:flutter_test/flutter_test.dart';
import 'package:ship_link/core/services/driver/marker_interpolation.dart';
import 'package:ship_link/core/maps/models/map_coordinate.dart';
import 'package:ship_link/core/maps/route_deviation.dart';

void main() {
  group('MarkerInterpolator', () {
    test('eases toward target over steps', () {
      final i = MarkerInterpolator(30.0, 31.0);
      for (var k = 0; k < 60; k++) {
        i.step(targetLat: 30.001, targetLng: 31.001);
      }
      expect(i.lat, closeTo(30.001, 1e-6));
      expect(i.lng, closeTo(31.001, 1e-6));
    });

    test('snaps on implausibly large jump', () {
      final i = MarkerInterpolator(30.0, 31.0);
      i.step(targetLat: 31.5, targetLng: 32.0, snapDistanceMeters: 200);
      expect(i.lat, closeTo(31.5, 1e-6));
      expect(i.lng, closeTo(32.0, 1e-6));
    });

    test('does not snap on a normal move', () {
      final i = MarkerInterpolator(30.0, 31.0);
      i.step(targetLat: 30.0005, targetLng: 31.0005, snapDistanceMeters: 200);
      expect(i.lat, isNot(closeTo(30.0005, 1e-9)));
    });
  });

  group('distanceMeters / bearing', () {
    test('distance between two close points is positive', () {
      final d = distanceMeters(30.0, 31.0, 30.001, 31.0);
      expect(d, greaterThan(0));
      expect(d, lessThan(200));
    });

    test('bearing points roughly north-east', () {
      final b = bearingBetween(30.0, 31.0, 30.001, 31.001);
      expect(b, greaterThan(0));
      expect(b, lessThan(90));
    });
  });

  group('RouteDeviation', () {
    final dev = RouteDeviation(toleranceMeters: 40);

    test('on-route point has small deviation', () {
      final route = [
        MapCoordinate(30.0, 31.0),
        MapCoordinate(30.01, 31.01),
      ];
      final onRoute = dev.deviationMeters(MapCoordinate(30.005, 31.005), route);
      expect(onRoute, lessThan(40));
    });

    test('far point is off-route', () {
      final route = [
        MapCoordinate(30.0, 31.0),
        MapCoordinate(30.01, 31.01),
      ];
      final off = dev.deviationMeters(MapCoordinate(30.2, 31.2), route);
      expect(off, greaterThan(40));
      expect(dev.isOffRoute(MapCoordinate(30.2, 31.2), route), isTrue);
    });
  });

  group('RouteRefreshPolicy', () {
    test('blocks refresh without meaningful movement', () {
      final p = RouteRefreshPolicy(minMoveMeters: 25, minInterval: const Duration(seconds: 10));
      final now = DateTime.now();
      expect(p.shouldRefresh(origin: MapCoordinate(30.0, 31.0), now: now), isNotNull);
      // same spot => blocked
      expect(p.shouldRefresh(origin: MapCoordinate(30.0, 31.0), now: now.add(const Duration(seconds: 1))), isNull);
      // moved enough + interval passed => allowed
      expect(p.shouldRefresh(origin: MapCoordinate(30.001, 31.001), now: now.add(const Duration(seconds: 11))), isNotNull);
    });

    test('accept honors only latest sequence', () {
      final p = RouteRefreshPolicy();
      final now = DateTime.now();
      final a = p.shouldRefresh(origin: MapCoordinate(30.0, 31.0), now: now)!;
      final b = p.shouldRefresh(origin: MapCoordinate(30.01, 31.01), now: now.add(const Duration(minutes: 1)))!;
      expect(p.accept(a), isFalse);
      expect(p.accept(b), isTrue);
    });

    test('forceRefresh bypasses move guard but respects interval', () {
      final p = RouteRefreshPolicy(minInterval: const Duration(seconds: 10));
      final now = DateTime.now();
      final a = p.forceRefresh(origin: MapCoordinate(30.0, 31.0), now: now)!;
      expect(p.forceRefresh(origin: MapCoordinate(30.0, 31.0), now: now.add(const Duration(seconds: 1))), isNull);
      expect(p.forceRefresh(origin: MapCoordinate(30.0, 31.0), now: now.add(const Duration(seconds: 11))), isNotNull);
      expect(p.accept(a), isFalse);
    });
  });
}

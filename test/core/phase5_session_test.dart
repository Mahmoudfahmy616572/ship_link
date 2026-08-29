import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ship_link/core/services/driver/driver_tracking_session.dart';
import 'package:ship_link/core/services/driver/tracking_state.dart';

Position p(double lat, double lng,
    {double accuracy = 5, DateTime? timestamp, double? speed}) {
  return Position(
    latitude: lat,
    longitude: lng,
    timestamp: timestamp ?? DateTime.now(),
    accuracy: accuracy,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: speed ?? 0,
    speedAccuracy: 0,
    isMocked: false,
  );
}

void main() {
  group('DriverTrackingSession', () {
    test('start returns false when permission denied', () async {
      final s = DriverTrackingSession(
        permissionRequester: () async => false,
        driverIdProvider: () => 'drv-1',
      );
      expect(await s.start(), isFalse);
      expect(s.state, DriverTrackingState.stopped);
    });

    test('start returns false when driver id missing', () async {
      final s = DriverTrackingSession(
        permissionRequester: () async => true,
        driverIdProvider: () => null,
      );
      expect(await s.start(), isFalse);
      expect(s.state, DriverTrackingState.stopped);
    });

    test('start is idempotent (single stream, single writer)', () async {
      var factoryCalls = 0;
      final controller = StreamController<Position>.broadcast();
      final s = DriverTrackingSession(
        positionStreamFactory: (_) {
          factoryCalls++;
          return controller.stream;
        },
        permissionRequester: () async => true,
        driverIdProvider: () => 'drv-1',
        writer: (_) async {},
      );
      expect(await s.start(), isTrue);
      expect(await s.start(), isTrue);
      expect(s.state, DriverTrackingState.active);
      expect(factoryCalls, 1);
      await s.stop();
    });

    test('rejects impossible jump, keeps valid points', () async {
      final written = <List<double>>[];
      final controller = StreamController<Position>.broadcast();
      final s = DriverTrackingSession(
        positionStreamFactory: (_) => controller.stream,
        permissionRequester: () async => true,
        driverIdProvider: () => 'drv-1',
        writer: (row) async {
          written.add([row['latitude'] as double, row['longitude'] as double]);
        },
      );
      await s.start();
      controller.add(p(30.0, 31.0));
      await Future.delayed(const Duration(milliseconds: 50));
      controller.add(p(30.18, 31.0)); // ~20km jump
      await Future.delayed(const Duration(milliseconds: 50));
      controller.add(p(30.0001, 31.0001));
      await Future.delayed(const Duration(milliseconds: 50));
      await s.stop();

      final lats = written.map((e) => e[0]).toList();
      expect(lats, contains(30.0));
      expect(lats, contains(closeTo(30.0001, 1e-4)));
      expect(lats, isNot(contains(closeTo(30.18, 1e-6))));
    });

    test('bounded retry publishes after transient writer failures', () async {
      var calls = 0;
      final controller = StreamController<Position>.broadcast();
      final s = DriverTrackingSession(
        positionStreamFactory: (_) => controller.stream,
        permissionRequester: () async => true,
        driverIdProvider: () => 'drv-1',
        writer: (row) async {
          calls++;
          if (calls < 3) throw Exception('transient');
        },
      );
      await s.start();
      controller.add(p(30.0, 31.0));
      await Future.delayed(const Duration(seconds: 5));
      expect(calls, greaterThanOrEqualTo(3));
      expect(s.state, DriverTrackingState.active);
      await s.stop();
    });

    test('persistent failure moves to reconnecting without crashing', () async {
      final controller = StreamController<Position>.broadcast();
      final s = DriverTrackingSession(
        positionStreamFactory: (_) => controller.stream,
        permissionRequester: () async => true,
        driverIdProvider: () => 'drv-1',
        writer: (_) async => throw Exception('down'),
      );
      addTearDown(() => s.stop());
      await s.start();
      controller.add(p(30.0, 31.0));
      await Future.delayed(const Duration(milliseconds: 3500));
      expect(s.state, DriverTrackingState.reconnecting);
    });
  });
}

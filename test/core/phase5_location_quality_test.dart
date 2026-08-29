import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ship_link/core/services/driver/location_quality_filter.dart';
import 'package:ship_link/core/models/tracking_freshness.dart';
import 'package:ship_link/core/services/driver/tracking_state.dart';

Position pos(double lat, double lng,
    {double accuracy = 5, DateTime? timestamp, double? speed, double? heading}) {
  return Position(
    latitude: lat,
    longitude: lng,
    timestamp: timestamp ?? DateTime.now(),
    accuracy: accuracy,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: heading ?? 0,
    headingAccuracy: 0,
    speed: speed ?? 0,
    speedAccuracy: 0,
    isMocked: false,
  );
}

void main() {
  group('LocationQualityFilter', () {
    final filter = LocationQualityFilter();

    test('accepts a good-accuracy fix', () {
      final r = filter.evaluate(pos(30.0444, 31.2357, accuracy: 5));
      expect(r.accept, isTrue);
      expect(r.confidence, LocationConfidence.good);
    });

    test('rejects invalid coordinate', () {
      final r = filter.evaluate(pos(999, 31.2357));
      expect(r.accept, isFalse);
      expect(r.reason, 'invalid_coordinate');
    });

    test('rejects stale timestamp', () {
      final old = DateTime.now().subtract(const Duration(minutes: 5));
      final r = filter.evaluate(pos(30, 31, timestamp: old));
      expect(r.accept, isFalse);
      expect(r.reason, 'stale_timestamp');
    });

    test('rejects future timestamp', () {
      final future = DateTime.now().add(const Duration(minutes: 2));
      final r = filter.evaluate(pos(30, 31, timestamp: future));
      expect(r.accept, isFalse);
      expect(r.reason, 'future_timestamp');
    });

    test('rejects accuracy too poor', () {
      final r = filter.evaluate(pos(30, 31, accuracy: 150));
      expect(r.accept, isFalse);
      expect(r.reason, 'accuracy_too_poor');
    });

    test('accepts degraded accuracy with caution', () {
      final r = filter.evaluate(pos(30, 31, accuracy: 50));
      expect(r.accept, isTrue);
      expect(r.confidence, LocationConfidence.caution);
    });

    test('rejects impossible jump', () {
      final prev = pos(30.0, 31.0);
      // 20 km away 1 second later => implied ~20 km/s >> max.
      final jump = pos(30.18, 31.0, timestamp: prev.timestamp.add(const Duration(seconds: 1)));
      final r = filter.evaluate(jump, previous: prev);
      expect(r.accept, isFalse);
      expect(r.reason, 'impossible_jump');
    });

    test('accepts a small normal move', () {
      final prev = pos(30.0, 31.0);
      final move = pos(30.0001, 31.0001, timestamp: prev.timestamp.add(const Duration(seconds: 2)));
      final r = filter.evaluate(move, previous: prev);
      expect(r.accept, isTrue);
    });
  });

  group('TrackingFreshness', () {
    final f = TrackingFreshness();

    test('classifies live/recent/stale/offline', () {
      final now = DateTime.now();
      expect(f.classify(now.subtract(const Duration(seconds: 5))), LocationFreshness.live);
      expect(f.classify(now.subtract(const Duration(seconds: 40))), LocationFreshness.recent);
      expect(f.classify(now.subtract(const Duration(seconds: 90))), LocationFreshness.stale);
      expect(f.classify(now.subtract(const Duration(seconds: 300))), LocationFreshness.offline);
      expect(f.classify(null), LocationFreshness.unknown);
    });

    test('semantic online live vs stale vs offline', () {
      final now = DateTime.now();
      expect(
        f.semantic(updatedAt: now, isOnline: true),
        UserOnlineState.onlineLive,
      );
      expect(
        f.semantic(updatedAt: now.subtract(const Duration(seconds: 90)), isOnline: true),
        UserOnlineState.onlineStale,
      );
      expect(
        f.semantic(updatedAt: now, isOnline: false),
        UserOnlineState.offline,
      );
    });
  });
}

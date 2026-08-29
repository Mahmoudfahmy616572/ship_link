import 'package:geolocator/geolocator.dart';

/// Documented GPS quality policy. Thresholds are explicit so tracking behavior
/// is reproducible and auditable instead of relying on magic numbers.
class LocationQualityPolicy {
  const LocationQualityPolicy({
    this.goodAccuracyMeters = 20.0,
    this.poorAccuracyMeters = 60.0,
    this.maxPublishAccuracyMeters = 100.0,
    this.maxImpliedSpeedMps = 45.0,
    this.maxAge = const Duration(seconds: 60),
    this.futureSkew = const Duration(seconds: 5),
  });

  /// Accuracy at or below this is considered good and published normally.
  final double goodAccuracyMeters;

  /// Accuracy between [goodAccuracyMeters] and this is published cautiously.
  final double poorAccuracyMeters;

  /// Accuracy above this is rejected for publishing position (too unreliable).
  final double maxPublishAccuracyMeters;

  /// Implied speed above this (distance / elapsed) means an impossible jump.
  final double maxImpliedSpeedMps;

  /// A fix older than this is treated as stale and rejected.
  final Duration maxAge;

  /// A fix timestamped in the future beyond this skew is rejected.
  final Duration futureSkew;
}

enum LocationConfidence { good, caution, low, rejected }

class LocationQualityResult {
  const LocationQualityResult(this.confidence, this.accept, [this.reason]);

  final LocationConfidence confidence;
  final bool accept;
  final String? reason;
}

class LocationQualityFilter {
  const LocationQualityFilter([this.policy = const LocationQualityPolicy()]);

  final LocationQualityPolicy policy;

  LocationQualityResult evaluate(Position pos, {Position? previous}) {
    if (!_validCoord(pos.latitude, pos.longitude)) {
      return const LocationQualityResult(
          LocationConfidence.rejected, false, 'invalid_coordinate');
    }

    final now = DateTime.now();
    final age = now.difference(pos.timestamp);
    if (age > policy.maxAge) {
      return const LocationQualityResult(
          LocationConfidence.rejected, false, 'stale_timestamp');
    }
    if (pos.timestamp.isAfter(now.add(policy.futureSkew))) {
      return const LocationQualityResult(
          LocationConfidence.rejected, false, 'future_timestamp');
    }

    final acc = pos.accuracy;
    if (acc > policy.maxPublishAccuracyMeters) {
      return const LocationQualityResult(
          LocationConfidence.rejected, false, 'accuracy_too_poor');
    }

    if (previous != null && _isImpossibleJump(previous, pos)) {
      return const LocationQualityResult(
          LocationConfidence.rejected, false, 'impossible_jump');
    }

    if (acc <= policy.goodAccuracyMeters) {
      return const LocationQualityResult(LocationConfidence.good, true);
    }
    if (acc <= policy.poorAccuracyMeters) {
      return const LocationQualityResult(
          LocationConfidence.caution, true, 'degraded_accuracy');
    }
    return const LocationQualityResult(
        LocationConfidence.low, true, 'low_accuracy');
  }

  bool _isImpossibleJump(Position a, Position b) {
    final jump = Geolocator.distanceBetween(
      a.latitude,
      a.longitude,
      b.latitude,
      b.longitude,
    );
    final dtMs = b.timestamp.difference(a.timestamp).inMilliseconds;
    if (dtMs <= 0) return false;
    final implied = jump / (dtMs / 1000);
    return implied > policy.maxImpliedSpeedMps;
  }

  static bool _validCoord(double lat, double lng) =>
      lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
}

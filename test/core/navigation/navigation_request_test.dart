import 'package:flutter_test/flutter_test.dart';
import 'package:ship_link/core/services/navigation/navigation_request.dart';

void main() {
  group('NavigationRequest validation', () {
    test('valid with origin and destination', () {
      final r = NavigationRequest(
        origin: NavCoordinate(30.0, 31.0),
        destination: NavCoordinate(30.1, 31.1),
      );
      expect(r.isValid, isTrue);
    });

    test('valid without origin (navigate from current location)', () {
      final r = NavigationRequest(destination: NavCoordinate(30.1, 31.1));
      expect(r.isValid, isTrue);
    });

    test('rejects invalid latitude', () {
      final r = NavigationRequest(destination: NavCoordinate(91.0, 31.0));
      expect(r.isValid, isFalse);
    });

    test('rejects invalid longitude', () {
      final r = NavigationRequest(destination: NavCoordinate(30.0, 181.0));
      expect(r.isValid, isFalse);
    });

    test('rejects invalid origin', () {
      final r = NavigationRequest(
        origin: NavCoordinate(91.0, 0.0),
        destination: NavCoordinate(30.0, 31.0),
      );
      expect(r.isValid, isFalse);
    });

    test('rejects (0,0) sentinel destination', () {
      final r = NavigationRequest(destination: NavCoordinate(0.0, 0.0));
      expect(r.isValid, isFalse);
    });

    test('rejects NaN coordinate', () {
      final r = NavigationRequest(destination: NavCoordinate(double.nan, 31.0));
      expect(r.isValid, isFalse);
    });
  });
}

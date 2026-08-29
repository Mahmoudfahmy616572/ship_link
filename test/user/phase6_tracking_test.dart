import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:ship_link/user/presentation/screens/tracking/driver_tracking_screen.dart';

void main() {
  group('parseTrackingOrderId', () {
    test('returns null for null/empty/whitespace', () {
      expect(parseTrackingOrderId(null), isNull);
      expect(parseTrackingOrderId(''), isNull);
      expect(parseTrackingOrderId('   '), isNull);
    });

    test('trims and keeps valid id', () {
      expect(parseTrackingOrderId('123'), '123');
      expect(parseTrackingOrderId(' 456 '), '456');
    });

    test('coerces numeric types to string id', () {
      expect(parseTrackingOrderId(77), '77');
      expect(parseTrackingOrderId(12.9), '12');
    });
  });

  group('TrackingProgressStepper.stepForStatus', () {
    test('maps real order statuses to driver-side steps', () {
      expect(TrackingProgressStepper.stepForStatus('accepted'), 0);
      expect(TrackingProgressStepper.stepForStatus('picked_up'), 1);
      expect(TrackingProgressStepper.stepForStatus('shipped'), 2);
      expect(TrackingProgressStepper.stepForStatus('in_transit'), 2);
      expect(TrackingProgressStepper.stepForStatus('delivered'), 3);
      expect(TrackingProgressStepper.stepForStatus('cancelled'), 0);
      expect(TrackingProgressStepper.stepForStatus('something_else'), 0);
    });
  });

  group('TrackingProgressStepper widget', () {
    Widget _buildStepper(String status) => MaterialApp(
          home: Builder(
            builder: (context) {
              Sizer.init(context);
              return Scaffold(body: TrackingProgressStepper(status: status));
            },
          ),
        );

    testWidgets('renders 4 step labels without crashing', (tester) async {
      await tester.pumpWidget(_buildStepper('picked_up'));
      await tester.pumpAndSettle();
      expect(find.text('Accepted'), findsOneWidget);
      expect(find.text('Picked Up'), findsOneWidget);
      expect(find.text('In Transit'), findsOneWidget);
      expect(find.text('Delivered'), findsOneWidget);
    });

    testWidgets('shows a check icon for completed steps', (tester) async {
      await tester.pumpWidget(_buildStepper('picked_up'));
      await tester.pumpAndSettle();
      // accepted (0) is completed (< current step 1) -> 1 check icon.
      expect(find.byIcon(Icons.check), findsNWidgets(1));
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:ship_link/web/presentation/screens/tracking/tracking_web.dart';

void main() {
  group('WebTrackingStepper.stepForStatus (Phase 7 web parity)', () {
    test('maps order statuses to the correct step index', () {
      expect(WebTrackingStepper.stepForStatus('accepted'), 0);
      expect(WebTrackingStepper.stepForStatus('picked_up'), 1);
      expect(WebTrackingStepper.stepForStatus('shipped'), 2);
      expect(WebTrackingStepper.stepForStatus('in_transit'), 2);
      expect(WebTrackingStepper.stepForStatus('delivered'), 3);
    });

    test('unknown status defaults to first step', () {
      expect(WebTrackingStepper.stepForStatus('whatever'), 0);
    });
  });
}

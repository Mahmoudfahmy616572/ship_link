import 'package:ship_link/core/services/navigation/navigation_provider.dart';
import 'package:ship_link/core/services/navigation/navigation_request.dart';

/// External navigation via Waze. Waze navigates from the device's current
/// location to the destination; it does not accept an explicit origin in its
/// simple deep link, so [NavigationRequest.origin] is intentionally ignored.
class WazeNavigationProvider extends NavigationProvider {
  const WazeNavigationProvider();

  @override
  String get name => 'waze';

  @override
  Uri buildUri(NavigationRequest request) {
    return Uri.https('waze.com', '/ul', {
      'll': request.destination.toString(),
      'navigate': 'yes',
    });
  }
}

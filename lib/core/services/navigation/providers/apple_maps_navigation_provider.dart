import 'package:ship_link/core/services/navigation/navigation_provider.dart';
import 'package:ship_link/core/services/navigation/navigation_request.dart';

/// External navigation via Apple Maps (iOS). The deep link is handled by the
/// system and routed to the Apple Maps app.
class AppleMapsNavigationProvider extends NavigationProvider {
  const AppleMapsNavigationProvider();

  @override
  String get name => 'apple';

  static String _dirFlag(TravelMode mode) {
    switch (mode) {
      case TravelMode.driving:
        return 'd';
      case TravelMode.walking:
        return 'w';
      case TravelMode.bicycling:
        return 'b';
      case TravelMode.transit:
        return 'r';
    }
  }

  @override
  Uri buildUri(NavigationRequest request) {
    final params = <String, String>{
      'dirflg': _dirFlag(request.travelMode),
      'daddr': request.destination.toString(),
    };
    if (request.origin != null) {
      params['saddr'] = request.origin.toString();
    }
    return Uri.https('maps.apple.com', '/', params);
  }
}

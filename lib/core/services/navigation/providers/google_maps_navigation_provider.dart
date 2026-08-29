import 'package:ship_link/core/services/navigation/navigation_provider.dart';
import 'package:ship_link/core/services/navigation/navigation_request.dart';

/// External navigation via Google Maps (native app when installed, otherwise the
/// web directions page in a browser). The URL construction lives here only.
class GoogleMapsNavigationProvider extends NavigationProvider {
  const GoogleMapsNavigationProvider();

  @override
  String get name => 'google';

  @override
  Uri buildUri(NavigationRequest request) {
    final params = <String, String>{
      'api': '1',
      'travelmode': request.travelMode.mapsValue,
      'destination': request.destination.toString(),
    };
    if (request.origin != null) {
      params['origin'] = request.origin.toString();
    }
    return Uri.https('www.google.com', '/maps/dir/', params);
  }
}

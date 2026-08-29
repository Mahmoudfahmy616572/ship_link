import 'package:ship_link/core/services/navigation/navigation_provider.dart';
import 'package:ship_link/core/services/navigation/navigation_request.dart';

/// Web fallback provider. On a browser the driver cannot open a native app, so
/// we open the Google Maps directions page directly. URL construction stays
/// inside this provider; feature screens must never build maps URLs themselves.
class WebNavigationProvider extends NavigationProvider {
  const WebNavigationProvider();

  @override
  String get name => 'web';

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

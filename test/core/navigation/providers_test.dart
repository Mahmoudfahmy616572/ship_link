import 'package:flutter_test/flutter_test.dart';
import 'package:ship_link/core/services/navigation/navigation_request.dart';
import 'package:ship_link/core/services/navigation/providers/apple_maps_navigation_provider.dart';
import 'package:ship_link/core/services/navigation/providers/google_maps_navigation_provider.dart';
import 'package:ship_link/core/services/navigation/providers/waze_navigation_provider.dart';
import 'package:ship_link/core/services/navigation/providers/web_navigation_provider.dart';

void main() {
  final req = NavigationRequest(
    origin: NavCoordinate(30.0, 31.0),
    destination: NavCoordinate(29.9, 31.2),
  );

  test('google builds https dir url with origin, destination and travelmode', () {
    final uri = const GoogleMapsNavigationProvider().buildUri(req);
    expect(uri.scheme, 'https');
    expect(uri.host, 'www.google.com');
    expect(uri.path, '/maps/dir/');
    expect(uri.queryParameters['api'], '1');
    expect(uri.queryParameters['origin'], '30.0,31.0');
    expect(uri.queryParameters['destination'], '29.9,31.2');
    expect(uri.queryParameters['travelmode'], 'driving');
  });

  test('google without origin omits origin param', () {
    final uri = const GoogleMapsNavigationProvider()
        .buildUri(NavigationRequest(destination: NavCoordinate(29.9, 31.2)));
    expect(uri.queryParameters.containsKey('origin'), isFalse);
    expect(uri.queryParameters['destination'], '29.9,31.2');
  });

  test('waze builds ul url with destination', () {
    final uri = const WazeNavigationProvider().buildUri(req);
    expect(uri.scheme, 'https');
    expect(uri.host, 'waze.com');
    expect(uri.path, '/ul');
    expect(uri.queryParameters['ll'], '29.9,31.2');
    expect(uri.queryParameters['navigate'], 'yes');
  });

  test('apple builds maps.apple.com with daddr and saddr', () {
    final uri = const AppleMapsNavigationProvider().buildUri(req);
    expect(uri.scheme, 'https');
    expect(uri.host, 'maps.apple.com');
    expect(uri.queryParameters['daddr'], '29.9,31.2');
    expect(uri.queryParameters['saddr'], '30.0,31.0');
  });

  test('apple without origin omits saddr', () {
    final uri = const AppleMapsNavigationProvider()
        .buildUri(NavigationRequest(destination: NavCoordinate(29.9, 31.2)));
    expect(uri.queryParameters.containsKey('saddr'), isFalse);
  });

  test('web fallback builds google dir url', () {
    final uri = const WebNavigationProvider().buildUri(req);
    expect(uri.host, 'www.google.com');
    expect(uri.path, '/maps/dir/');
    expect(uri.queryParameters['destination'], '29.9,31.2');
  });
}

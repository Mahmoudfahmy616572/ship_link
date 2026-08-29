import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ship_link/core/services/navigation/external_navigation_service.dart';
import 'package:ship_link/core/services/navigation/navigation_request.dart';
import 'package:ship_link/core/services/navigation/navigation_result.dart';
import 'package:ship_link/core/services/navigation/providers/google_maps_navigation_provider.dart';
import 'package:ship_link/core/services/navigation/providers/web_navigation_provider.dart';

NavigationRequest get req => NavigationRequest(destination: NavCoordinate(29.9, 31.2));

void main() {
  test('first provider available -> launched', () async {
    final service = ExternalNavigationService(
      providers: const [GoogleMapsNavigationProvider(), WebNavigationProvider()],
      canLaunch: (_) async => true,
      launch: (_ , {LaunchMode mode = LaunchMode.platformDefault}) async => true,
    );
    final r = await service.navigate(req);
    expect(r.success, isTrue);
    expect(r.providerName, 'google');
  });

  test('first unavailable -> fallback succeeds', () async {
    var canLaunchCalls = 0;
    final service = ExternalNavigationService(
      providers: const [GoogleMapsNavigationProvider(), WebNavigationProvider()],
      canLaunch: (_) async {
        canLaunchCalls++;
        return canLaunchCalls == 1 ? false : true;
      },
      launch: (_ , {LaunchMode mode = LaunchMode.platformDefault}) async => true,
    );
    final r = await service.navigate(req);
    expect(r.success, isTrue);
    expect(r.providerName, 'web');
  });

  test('all providers fail to launch -> noProvider', () async {
    final service = ExternalNavigationService(
      providers: const [GoogleMapsNavigationProvider(), WebNavigationProvider()],
      canLaunch: (_) async => true,
      launch: (_ , {LaunchMode mode = LaunchMode.platformDefault}) async => false,
    );
    final r = await service.navigate(req);
    expect(r.success, isFalse);
    expect(r.status, NavigationStatus.noProvider);
  });

  test('first provider throws -> fallback used', () async {
    var calls = 0;
    final service = ExternalNavigationService(
      providers: const [GoogleMapsNavigationProvider(), WebNavigationProvider()],
      canLaunch: (_) async => true,
      launch: (uri, {LaunchMode mode = LaunchMode.platformDefault}) {
        calls++;
        if (calls == 1) throw Exception('boom');
        return Future.value(true);
      },
    );
    final r = await service.navigate(req);
    expect(r.success, isTrue);
    expect(r.providerName, 'web');
  });

  test('invalid request -> invalidRequest, no launch attempted', () async {
    var launched = false;
    final service = ExternalNavigationService(
      providers: const [GoogleMapsNavigationProvider()],
      canLaunch: (_) async => true,
      launch: (_ , {LaunchMode mode = LaunchMode.platformDefault}) async {
        launched = true;
        return true;
      },
    );
    final r = await service.navigate(NavigationRequest(destination: NavCoordinate(0.0, 0.0)));
    expect(r.status, NavigationStatus.invalidRequest);
    expect(r.success, isFalse);
    expect(launched, isFalse);
  });
}

import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ship_link/core/services/navigation/navigation_provider.dart';
import 'package:ship_link/core/services/navigation/navigation_request.dart';
import 'package:ship_link/core/services/navigation/navigation_result.dart';
import 'package:ship_link/core/services/navigation/providers/apple_maps_navigation_provider.dart';
import 'package:ship_link/core/services/navigation/providers/google_maps_navigation_provider.dart';
import 'package:ship_link/core/services/navigation/providers/waze_navigation_provider.dart';
import 'package:ship_link/core/services/navigation/providers/web_navigation_provider.dart';

/// Decides which external navigation application to use and launches it.
///
/// Feature screens (Driver UI) only call [navigate] with a [NavigationRequest];
/// they never build provider-specific URLs. Selection order:
///
///   Web        -> web (browser directions)
///   iOS        -> Apple Maps -> Google Maps -> Waze -> web fallback
///   Android/*  -> Google Maps -> Waze -> web fallback
///
/// On Huawei / No-GMS Android, Google Maps may be unavailable; the https URL
/// still opens in the device browser via the web fallback provider, so the
/// driver app never crashes. No provider availability is *assumed*: we attempt
/// each in order and stop at the first that launches.
class ExternalNavigationService {
  final List<NavigationProvider> _providers;
  final Future<bool> Function(Uri uri, {LaunchMode mode}) _launch;
  final Future<bool> Function(Uri uri) _canLaunch;

  ExternalNavigationService({
    List<NavigationProvider>? providers,
    Future<bool> Function(Uri uri, {LaunchMode mode})? launch,
    Future<bool> Function(Uri uri)? canLaunch,
  })  : _providers = providers ?? _defaultProviders(),
        _launch = launch ?? launchUrl,
        _canLaunch = canLaunch ?? canLaunchUrl;

  static List<NavigationProvider> _defaultProviders() {
    if (kIsWeb) {
      return const [WebNavigationProvider()];
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return const [
        AppleMapsNavigationProvider(),
        GoogleMapsNavigationProvider(),
        WazeNavigationProvider(),
        WebNavigationProvider(),
      ];
    }
    // Android and any other platform (incl. Huawei / No-GMS).
    return const [
      GoogleMapsNavigationProvider(),
      WazeNavigationProvider(),
      WebNavigationProvider(),
    ];
  }

  /// Attempt to launch an external navigation app for [request].
  ///
  /// Returns a neutral [NavigationResult]; never throws.
  Future<NavigationResult> navigate(NavigationRequest request) async {
    if (!request.isValid) {
      return const NavigationResult.invalidRequest();
    }

    String? lastAttempted;
    for (final provider in _providers) {
      lastAttempted = provider.name;
      final uri = provider.buildUri(request);
      try {
        if (await _canLaunch(uri)) {
          final launched = await _launch(uri, mode: LaunchMode.externalApplication);
          if (launched) {
            debugPrint('ExternalNavigation: launched via ${provider.name}');
            return NavigationResult.launched(provider.name);
          }
        }
      } catch (e) {
        debugPrint('ExternalNavigation: provider ${provider.name} failed: $e');
      }
    }
    return NavigationResult.noProvider(lastAttempted);
  }
}

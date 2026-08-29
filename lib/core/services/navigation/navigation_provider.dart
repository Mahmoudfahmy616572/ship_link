import 'package:ship_link/core/services/navigation/navigation_request.dart';

/// Minimal, provider-agnostic navigation abstraction.
///
/// Implementations own the URL/deep-link construction for a specific external
/// navigation application. They must NOT be referenced directly by feature
/// screens; only [ExternalNavigationService] knows about concrete providers.
abstract class NavigationProvider {
  const NavigationProvider();

  /// Human-readable provider name (e.g. 'google', 'waze', 'apple', 'web').
  String get name;

  /// Build the launch URI for the given request.
  ///
  /// Implementations must encode coordinates and labels safely and must not
  /// embed any secrets, tokens, or phone numbers.
  Uri buildUri(NavigationRequest request);
}

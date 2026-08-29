import 'package:ship_link/core/maps/interfaces/route_service.dart';
import 'package:ship_link/core/maps/models/map_coordinate.dart';
import 'package:ship_link/core/maps/models/route_result.dart';

/// Tries [primary]; on null/error falls back to [fallback]. Keeps feature code
/// provider-independent and guarantees zero-regression: if the new Egypt routing
/// provider is unconfigured or fails, the previous provider still serves real
/// road routes.
class FallbackRouteService implements RouteService {
  final RouteService primary;
  final RouteService fallback;

  const FallbackRouteService({
    required this.primary,
    required this.fallback,
  });

  @override
  Future<RouteResult?> getRoute({
    required MapCoordinate origin,
    required MapCoordinate destination,
  }) async {
    try {
      final r = await primary.getRoute(origin: origin, destination: destination);
      if (r != null) return r;
    } catch (_) {}
    try {
      return await fallback.getRoute(origin: origin, destination: destination);
    } catch (_) {
      return null;
    }
  }
}

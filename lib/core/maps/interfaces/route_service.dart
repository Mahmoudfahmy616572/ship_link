import 'package:ship_link/core/maps/models/map_coordinate.dart';
import 'package:ship_link/core/maps/models/route_result.dart';

/// Abstraction over route computation. The feature/tracking layer depends
/// only on this interface and on [RouteResult]; it never references the
/// concrete Google Directions implementation or its response types.
abstract class RouteService {
  Future<RouteResult?> getRoute({
    required MapCoordinate origin,
    required MapCoordinate destination,
  });
}

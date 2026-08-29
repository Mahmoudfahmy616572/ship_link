import 'package:ship_link/core/maps/models/map_coordinate.dart';
import 'package:ship_link/core/widgets/adaptive_map.dart';

/// Adapts the domain [MapCoordinate] to/from the renderer-neutral
/// [MapLatLng] used by [AdaptiveMap]. Keeps provider-specific types
/// (google_maps_flutter / flutter_map) confined to the renderer layer.
extension MapCoordinateAdapter on MapCoordinate {
  MapLatLng toMapLatLng() => MapLatLng(latitude, longitude);
}

extension MapLatLngAdapter on MapLatLng {
  MapCoordinate toCoordinate() => MapCoordinate(latitude, longitude);
}

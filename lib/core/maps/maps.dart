import 'package:ship_link/core/maps/interfaces/geocoding_provider.dart';
import 'package:ship_link/core/maps/interfaces/route_service.dart';
import 'package:ship_link/core/maps/providers/fallback_geocoding_provider.dart';
import 'package:ship_link/core/maps/providers/fallback_route_service.dart';
import 'package:ship_link/core/maps/providers/google_directions_route_provider.dart';
import 'package:ship_link/core/maps/providers/graphhopper_route_provider.dart';
import 'package:ship_link/core/maps/providers/maptiler_geocoding_provider.dart';
import 'package:ship_link/core/maps/providers/nominatim_geocoding_provider.dart';
import 'package:ship_link/core/maps/providers/polyline_decoder.dart';

export 'models/map_coordinate.dart';
export 'models/route_result.dart';
export 'models/geocoding_result.dart';
export 'interfaces/route_service.dart';
export 'interfaces/geocoding_provider.dart';
export 'providers/google_directions_route_provider.dart';
export 'providers/graphhopper_route_provider.dart';
export 'providers/maptiler_geocoding_provider.dart';
export 'providers/nominatim_geocoding_provider.dart';
export 'providers/fallback_route_service.dart';
export 'providers/fallback_geocoding_provider.dart';
export 'providers/polyline_decoder.dart';
export 'region/region_config.dart';
export 'renderer/maptiler_config.dart';
export 'adapters/map_coordinate_adapter.dart';

/// Single swap point for routing. New Egypt provider (GraphHopper) is primary;
/// Google Directions remains the fallback until live validation retires it.
RouteService get routeService => FallbackRouteService(
      primary: GraphHopperRouteProvider(),
      fallback: GoogleDirectionsRouteProvider(),
    );

/// Single swap point for geocoding. MapTiler Geocoding (forward + reverse) is
/// primary with Egypt bbox/language filtering; Nominatim is the fallback.
GeocodingProvider get geocodingService => FallbackGeocodingProvider(
      primary: MapTilerGeocodingProvider(),
      fallback: NominatimGeocodingProvider(),
    );

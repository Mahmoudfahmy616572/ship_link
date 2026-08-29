import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:ship_link/core/maps/interfaces/geocoding_provider.dart';
import 'package:ship_link/core/maps/interfaces/route_service.dart';
import 'package:ship_link/core/maps/models/geocoding_result.dart';
import 'package:ship_link/core/maps/models/map_coordinate.dart';
import 'package:ship_link/core/maps/models/route_result.dart';
import 'package:ship_link/core/maps/providers/fallback_geocoding_provider.dart';
import 'package:ship_link/core/maps/providers/fallback_route_service.dart';
import 'package:ship_link/core/maps/providers/google_directions_route_provider.dart';
import 'package:ship_link/core/maps/providers/graphhopper_route_provider.dart';
import 'package:ship_link/core/maps/providers/maptiler_geocoding_provider.dart';
import 'package:ship_link/core/maps/providers/nominatim_geocoding_provider.dart';

/// Records requested URLs and returns canned JSON bodies by substring match.
class _FakeClient extends http.BaseClient {
  final Map<String, String> bodies;
  final List<String> captured = [];
  _FakeClient(this.bodies);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    captured.add(request.url.toString());
    final url = request.url.toString();
    var body = '{}';
    for (final key in bodies.keys) {
      if (url.contains(key)) {
        body = bodies[key]!;
        break;
      }
    }
    return http.StreamedResponse(
      Stream.value(Uint8List.fromList(utf8.encode(body))),
      200,
      request: request,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  }
}

/// Minimal route fixture (encoded polyline decodes to 3 points).
const _ghRoute = '''{
  "paths": [
    {
      "distance": 8500.0,
      "time": 900000,
      "points_encoded": true,
      "points": "_p~iF~ps|U_ulLnnqC_mqNvxq\`@"
    }
  ]
}''';

const _mtForward = '''{
  "features": [
    {
      "text": "مدينة نصر",
      "place_name": "مدينة نصر, Cairo, Egypt",
      "geometry": {"type": "Point", "coordinates": [31.34, 30.05]},
      "properties": {"name": "مدينة نصر", "city": "Cairo", "region": "Cairo", "country": "Egypt"}
    }
  ]
}''';

const _mtReverse = '''{
  "features": [
    {
      "text": "القاهرة الجديدة",
      "place_name": "القاهرة الجديدة, Cairo, Egypt",
      "geometry": {"type": "Point", "coordinates": [31.45, 30.03]},
      "properties": {"name": "القاهرة الجديدة", "city": "Cairo", "region": "Cairo", "country": "Egypt"}
    }
  ]
}''';

const _nomSearch = '''[
  {
    "lat": "30.0444",
    "lon": "31.2357",
    "display_name": "Cairo, Egypt",
    "address": {"city": "Cairo", "state": "Cairo", "country": "Egypt"}
  }
]''';

const _nomReverse = '''{
  "display_name": "Cairo, Egypt",
  "address": {"road": "Tahrir", "city": "Cairo", "state": "Cairo", "country": "Egypt"}
}''';

void main() {
  group('GraphHopperRouteProvider', () {
    test('builds correct Egypt routing request', () async {
      final client = _FakeClient({});
      final provider = GraphHopperRouteProvider(
        client: client,
        apiKey: 'TESTKEY',
      );
      await provider.getRoute(
        origin: const MapCoordinate(30.0444, 31.2357),
        destination: const MapCoordinate(30.0131, 31.2089),
      );
      final url = client.captured.first;
      expect(url, contains('graphhopper.com/api/1/route'));
      expect(url, contains('vehicle=car'));
      expect(url, contains('points_encoded=true'));
      expect(url, contains('key=TESTKEY'));
      expect(url, contains('30.0444'));
      expect(url, contains('30.0131'));
    });

    test('parses route result (distance, ETA, geometry)', () async {
      final client = _FakeClient({'route': _ghRoute});
      final provider = GraphHopperRouteProvider(
        client: client,
        apiKey: 'TESTKEY',
      );
      final route = await provider.getRoute(
        origin: const MapCoordinate(30.0444, 31.2357),
        destination: const MapCoordinate(30.0131, 31.2089),
      );
      expect(route, isNotNull);
      expect(route!.distanceMeters, 8500.0);
      expect(route.durationSeconds, 900);
      expect(route.polylinePoints.length, 3);
      expect(route.provider, 'graphhopper');
      expect(route.isApproximate, isFalse);
    });

    test('returns null when unconfigured (falls back elsewhere)', () async {
      final provider = GraphHopperRouteProvider(apiKey: '');
      expect(await provider.getRoute(
        origin: const MapCoordinate(30, 31),
        destination: const MapCoordinate(30.1, 31.1),
      ), isNull);
    });

    test('returns null on empty paths (no route)', () async {
      final client = _FakeClient({'route': '{"paths":[]}'});
      final provider = GraphHopperRouteProvider(
        client: client,
        apiKey: 'TESTKEY',
      );
      expect(await provider.getRoute(
        origin: const MapCoordinate(30, 31),
        destination: const MapCoordinate(30.1, 31.1),
      ), isNull);
    });

    test('returns null on malformed response', () async {
      final client = _FakeClient({'route': 'not json'});
      final provider = GraphHopperRouteProvider(
        client: client,
        apiKey: 'TESTKEY',
      );
      expect(await provider.getRoute(
        origin: const MapCoordinate(30, 31),
        destination: const MapCoordinate(30.1, 31.1),
      ), isNull);
    });
  });

  group('MapTilerGeocodingProvider', () {
    test('reverse geocode parses Egyptian result', () async {
      final client = _FakeClient({'geocoding': _mtReverse});
      final provider = MapTilerGeocodingProvider(client: client, apiKey: 'TESTKEY');
      // bypass key requirement for unit test
      final result = await provider.reverseGeocode(const MapCoordinate(30.03, 31.45));
      expect(result, isNotNull);
      expect(result!.formattedAddress, contains('القاهرة الجديدة'));
      expect(result.city, 'Cairo');
      expect(result.governorate, 'Cairo');
      expect(result.coordinate.latitude, 30.03);
    });

    test('forward search parses results', () async {
      final client = _FakeClient({'geocoding': _mtForward});
      final provider = MapTilerGeocodingProvider(client: client, apiKey: 'TESTKEY');
      final results = await provider.search('مدينة نصر');
      expect(results, isNotEmpty);
      expect(results.first.city, 'Cairo');
      expect(results.first.coordinate.longitude, 31.34);
    });

    test('requests include Egypt bbox + country + language', () async {
      final client = _FakeClient({'geocoding': _mtForward});
      final provider = MapTilerGeocodingProvider(client: client, apiKey: 'TESTKEY');
      await provider.search('cairo');
      final url = client.captured.first;
      expect(url, contains('api.maptiler.com/geocoding/'));
      expect(url, contains('bbox=24.0'));
      expect(url, contains('32.0'));
      expect(url, contains('country=EG'));
      expect(url, contains('language=ar'));
    });

    test('returns null/empty when unconfigured', () async {
      final provider = MapTilerGeocodingProvider();
      expect(await provider.reverseGeocode(const MapCoordinate(30, 31)), isNull);
      expect(await provider.search('x'), isEmpty);
    });
  });

  group('NominatimGeocodingProvider', () {
    test('forward search parses result', () async {
      final client = _FakeClient({'search': _nomSearch});
      final provider = NominatimGeocodingProvider(client: client);
      final results = await provider.search('cairo');
      expect(results, isNotEmpty);
      expect(results.first.city, 'Cairo');
      expect(results.first.coordinate.latitude, 30.0444);
      expect(results.first.coordinate.longitude, 31.2357);
    });

    test('reverse geocode parses result', () async {
      final client = _FakeClient({'reverse': _nomReverse});
      final provider = NominatimGeocodingProvider(client: client);
      final result = await provider.reverseGeocode(const MapCoordinate(30, 31));
      expect(result, isNotNull);
      expect(result!.city, 'Cairo');
      expect(result.governorate, 'Cairo');
      expect(result.formattedAddress, contains('Tahrir'));
    });

    test('provider implements GeocodingProvider', () {
      expect(NominatimGeocodingProvider(), isA<GeocodingProvider>());
    });
  });

  group('Fallback composition', () {
    test('RouteService uses fallback when primary returns null', () async {
      final fallback = _FakeRoute(RouteResult(
        polylinePoints: [const MapCoordinate(30, 31)],
        distanceMeters: 1000,
        durationSeconds: 120,
        provider: 'fallback',
      ));
      final svc = FallbackRouteService(primary: _FakeRoute(null), fallback: fallback);
      final r = await svc.getRoute(
        origin: const MapCoordinate(30, 31),
        destination: const MapCoordinate(30.1, 31.1),
      );
      expect(r?.provider, 'fallback');
    });

    test('RouteService uses primary when available', () async {
      final primary = _FakeRoute(RouteResult(
        polylinePoints: [const MapCoordinate(30, 31)],
        provider: 'primary',
      ));
      final svc = FallbackRouteService(primary: primary, fallback: _FakeRoute(null));
      final r = await svc.getRoute(
        origin: const MapCoordinate(30, 31),
        destination: const MapCoordinate(30.1, 31.1),
      );
      expect(r?.provider, 'primary');
    });

    test('Geocoding fallback on reverse', () async {
      final fb = FallbackGeocodingProvider(
        primary: _FakeGeo(null),
        fallback: _FakeGeo(const GeocodingResult(
          formattedAddress: 'x',
          coordinate: MapCoordinate(30, 31),
        )),
      );
      final r = await fb.reverseGeocode(const MapCoordinate(30, 31));
      expect(r?.formattedAddress, 'x');
    });
  });
}

class _FakeRoute extends Fake implements RouteService {
  final RouteResult? result;
  _FakeRoute(this.result);
  @override
  Future<RouteResult?> getRoute({
    required MapCoordinate origin,
    required MapCoordinate destination,
  }) async =>
      result;
}

class _FakeGeo extends Fake implements GeocodingProvider {
  final GeocodingResult? result;
  _FakeGeo(this.result);
  @override
  Future<GeocodingResult?> reverseGeocode(MapCoordinate coordinate) async => result;
  @override
  Future<List<GeocodingResult>> search(
    String query, {
    String? language,
    String? countryCode,
    int limit = 5,
  }) async =>
      result == null ? const [] : [result!];
}

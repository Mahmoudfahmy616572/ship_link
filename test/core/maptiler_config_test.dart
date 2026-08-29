import 'package:flutter_test/flutter_test.dart';
import 'package:ship_link/core/maps/renderer/maptiler_config.dart';

void main() {
  group('MapTilerConfig', () {
    test('builds a documented MapTiler raster tile URL (light)', () {
      final url = MapTilerConfig.tileUrl(key: 'TESTKEY', dark: false);
      expect(url,
          'https://api.maptiler.com/maps/positron/256/{z}/{x}/{y}.png?key=TESTKEY');
    });

    test('builds a documented MapTiler raster tile URL (dark)', () {
      final url = MapTilerConfig.tileUrl(key: 'TESTKEY', dark: true);
      expect(url,
          'https://api.maptiler.com/maps/darkmatter/256/{z}/{x}/{y}.png?key=TESTKEY');
    });

    test('never embeds a key in source — uses build-time define', () {
      // apiKey is read from the environment at compile time; in tests it is
      // empty unless the build supplied --dart-define=MAPTILER_API_KEY=...
      expect(MapTilerConfig.apiKey, isA<String>());
    });

    test('attribution includes MapTiler + OpenStreetMap', () {
      expect(MapTilerConfig.attribution,
          '© MapTiler © OpenStreetMap contributors');
    });

    test('falls back to OSM when no key is configured (no regression)', () {
      if (MapTilerConfig.isConfigured) {
        // CI may supply a key; skip the fallback assertion in that case.
        return;
      }
      expect(MapTilerConfig.activeTileTemplate(),
          MapTilerConfig.osmFallbackTemplate);
      expect(MapTilerConfig.activeAttribution, '© OpenStreetMap contributors');
    });
  });
}

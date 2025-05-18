import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';


class MapCachingService {
  static const String _storeName = 'mapStore';
  static const String _downloadKey = 'canThoMapDownloaded';

  // Approximate Can Tho city bounds
  final LatLngBounds _canThoBounds = LatLngBounds(
    const LatLng(9.95, 105.65), // SW
    const LatLng(10.15, 105.85), // NE
  );

  static const int _minZoom = 10;
  static const int _maxZoom = 16;

  bool _isDownloading = false;

  /// Initialize the tile‐caching plugin and create a named store.
  Future<void> initialise() async {
    // Ensure FlutterMapTileCaching is initialized.
    await FMTCObjectBoxBackend.initialise();
    // Create the store if it doesn't already exist.
    await FM.store(_storeName).manage.create();
    debugPrint('MapCachingService: store "$_storeName" ready');
  }

  /// Returns a tile provider that serves from the cache (and falls back to network).
  TileProvider getTileProvider() {
    return FMTC.instance.store(_storeName).getTileProvider();
  }

  /// Downloads the tiles for the Can Tho region once.
  Future<void> downloadCanThoRegionIfNeeded() async {
    if (_isDownloading) return;

    final prefs = await SharedPreferences.getInstance();
    final already = prefs.getBool(_downloadKey) ?? false;
    if (already) return;

    _isDownloading = true;
    try {
      final store = FMTC.instance.store(_storeName);
      // downloadArea will fetch all tiles between minZoom..maxZoom within bounds
      final count = await store.manage.downloadArea(
        bounds: _canThoBounds,
        minZoom: _minZoom,
        maxZoom: _maxZoom,
        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      );
      debugPrint('MapCachingService: downloaded $count tiles');
      await prefs.setBool(_downloadKey, true);
    } catch (err) {
      debugPrint('MapCachingService: error downloading tiles: $err');
    } finally {
      _isDownloading = false;
    }
  }

  /// Clears the tile cache and resets the download flag.
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_downloadKey);
    await FMTC.instance.store(_storeName).manage.clearAll();
    debugPrint('MapCachingService: cache cleared');
  }
}

import 'dart:async';

import 'package:busmapcantho/data/model/bus_location.dart';
import 'package:busmapcantho/data/model/bus_stop.dart';
import 'package:busmapcantho/gen/assets.gen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart' as osm;
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart'; // Import package
import 'package:busmapcantho/services/map_caching_service.dart';
import 'package:busmapcantho/core/di/injection.dart';

typedef StopCallback = void Function(BusStop stop);
typedef VoidCallback = void Function();

class BusMapWidget extends StatefulWidget {
  final List<BusStop> busStops;
  final bool isLoading;
  final BusStop? selectedStop;
  final osm.LatLng userLocation;
  final StopCallback onStopSelected;
  final VoidCallback onClearSelectedStop;
  final VoidCallback refreshStops;
  final VoidCallback onCenterUser;
  final VoidCallback onDirections;
  final StopCallback onRoutes;

  /// Optional route polyline and labels.
  final List<osm.LatLng> routePoints;
  final String? distanceLabel;
  final String? durationLabel;
  final List<BusLocation>? busLocations; // Thêm prop mới cho busLocations

  const BusMapWidget({
    super.key,
    required this.busStops,
    required this.isLoading,
    required this.selectedStop,
    required this.userLocation,
    required this.onStopSelected,
    required this.onClearSelectedStop,
    required this.refreshStops,
    required this.onCenterUser,
    required this.onDirections,
    required this.onRoutes,
    this.routePoints = const [],
    this.distanceLabel,
    this.durationLabel,
    this.busLocations, // Thêm vào constructor
  });

  @override
  State<BusMapWidget> createState() => _BusMapWidgetState();
}

class _BusMapWidgetState extends State<BusMapWidget>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  static const _canThoCenter = osm.LatLng(10.0364634, 105.7875821);
  static const _initialZoom = 13.0;
  static const _markerVisibilityZoomThreshold = 13.0;

  late final AnimatedMapController _mapCtrl;
  late final StreamSubscription<MapEvent> _mapEventSub;
  double _currentZoom = _initialZoom;
  bool _showMarkers = true;
  late final TileProvider _tileProvider;

  @override
  void initState() {
    super.initState();
    // Obtain tile provider from caching service
    _tileProvider = getIt<MapCachingService>().getTileProvider();
    _mapCtrl = AnimatedMapController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _mapEventSub = _mapCtrl.mapController.mapEventStream.listen(_onMapEvent);
  }

  void _onMapEvent(MapEvent evt) {
    if (evt is MapEventMove && mounted) {
      setState(() {
        _currentZoom = evt.camera.zoom;
        _showMarkers = _currentZoom >= _markerVisibilityZoomThreshold;
      });
    }
  }

  @override
  void dispose() {
    _mapEventSub.cancel();
    _mapCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapCtrl.mapController,
          options: MapOptions(
            initialCenter: _canThoCenter,
            initialZoom: _initialZoom,
            minZoom: 10,
            maxZoom: 18,
            interactionOptions:
            const InteractionOptions(flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
            cameraConstraint: CameraConstraint.contain(
              bounds: LatLngBounds(
                osm.LatLng(9.9, 105.6),
                osm.LatLng(10.2, 105.9),
              ),
            ),
            onTap: (_, __) => widget.onClearSelectedStop(),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              tileProvider: _tileProvider, // Use cached TileProvider
              subdomains: const ['a', 'b', 'c'],
              userAgentPackageName: 'com.busmapcantho.app',
              additionalOptions: const {
                'attribution': '© OpenStreetMap contributors'
              },
            ),
            CurrentLocationLayer(),
            if (_showMarkers)
              MarkerLayer(
                markers: widget.busStops.map((stop) {
                  final isSelected = widget.selectedStop?.id == stop.id;
                  return Marker(
                    width: isSelected ? 40 : 32,
                    height: isSelected ? 40 : 32,
                    point: osm.LatLng(stop.latitude, stop.longitude),
                    child: GestureDetector(
                      onTap: () {
                        widget.onStopSelected(stop);
                        _mapCtrl.animateTo(
                          dest: osm.LatLng(stop.latitude, stop.longitude),
                          zoom: _currentZoom < 15 ? 15 : _currentZoom,
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.all(isSelected ? 2 : 0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? Colors.blue.shade300
                              : Colors.transparent,
                        ),
                        child: Image.asset(
                          Assets.images.busStops.path,
                          color: isSelected ? Colors.blue.shade700 : null,
                        ),
                      ),
                    ),
                  );
                }).toList()
                // ...existing code...
              ),
            // Hiển thị marker xe buýt
            if (widget.busLocations != null)
              MarkerLayer(
                markers: widget.busLocations!.map((bus) {
                  return Marker(
                    width: 32,
                    height: 32,
                    point: osm.LatLng(bus.lat, bus.lng),
                    child: Image.asset(
                      Assets.images.bus.path,
                      // Hoặc icon xe buýt phù hợp
                      width: 32,
                      height: 32,
                    ),
                  );
                }).toList().cast<Marker>(),
              ),
            // Draw route polyline if provided
            if (widget.routePoints.isNotEmpty)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: widget.routePoints,
                    color: Colors.blue,
                    strokeWidth: 4.0,
                  )
                ],
              ),
          ],
        ),

        // Zoom and refresh controls (unchanged)
        Positioned(
          bottom: 16,
          right: 16,
          child: Column(
            children: [
              FloatingActionButton(
                heroTag: 'zoom_in',
                mini: true,
                onPressed: () => _mapCtrl.animateTo(zoom: _currentZoom + 1),
                child: const Icon(Icons.add),
              ),
              const SizedBox(height: 4),
              FloatingActionButton(
                heroTag: 'zoom_out',
                mini: true,
                onPressed: () => _mapCtrl.animateTo(zoom: _currentZoom - 1),
                child: const Icon(Icons.remove),
              ),
            ],
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: Row(
            children: [
              FloatingActionButton(
                heroTag: 'reload_stops',
                mini: true,
                onPressed: widget.refreshStops,
                tooltip: 'reload'.tr(),
                child: const Icon(Icons.refresh),
              ),
              const SizedBox(width: 8),
              FloatingActionButton(
                heroTag: 'my_location',
                mini: true,
                onPressed: () {
                  _mapCtrl.animateTo(
                    dest: widget.userLocation,
                    zoom: _currentZoom < 15 ? 15 : _currentZoom,
                  );
                  widget.onCenterUser();
                },
                tooltip: 'myLocation'.tr(),
                child: const Icon(Icons.my_location),
              ),
            ],
          ),
        ),

        // Stop info card + actions
        if (widget.selectedStop != null)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Stop name & close
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.selectedStop!.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: widget.onClearSelectedStop,
                          tooltip: 'close'.tr(),
                        )
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Directions & Routes buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.directions, size: 18),
                          label: Text('directions'.tr()),
                          onPressed: widget.onDirections,
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.list, size: 18),
                          label: Text('routes'.tr()),
                          onPressed: () =>
                              widget.onRoutes(widget.selectedStop!),
                        ),
                      ],
                    ),

                    // Distance / Duration info
                    if (widget.routePoints.isNotEmpty &&
                        widget.distanceLabel != null &&
                        widget.durationLabel != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(widget.distanceLabel!,
                                style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                            Text(widget.durationLabel!,
                                style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                            TextButton(
                              onPressed: widget.onClearSelectedStop,
                              child: const Text('Clear'),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

        // Loading indicator
        if (widget.isLoading) const Center(child: CircularProgressIndicator()),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}


import 'dart:async';

import 'package:busmapcantho/data/model/bus_stop.dart';
import 'package:busmapcantho/gen/assets.gen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart' as osm;

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

  @override
  void initState() {
    super.initState();
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
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
            cameraConstraint: CameraConstraint.contain(
              bounds: LatLngBounds(
                osm.LatLng(9.9, 105.6),
                osm.LatLng(10.2, 105.9),
              ),
            ),
            onTap: (_, __) => widget.onClearSelectedStop(),
          ),
          children: [
            // OpenStreetMap tile layer
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
              userAgentPackageName: 'com.busmapcantho.app',
              additionalOptions: const {
                'attribution': '© OpenStreetMap contributors',
              },
            ),

            CurrentLocationLayer(),

            if (_showMarkers)
              MarkerLayer(
                markers:
                    widget.busStops.map((stop) {
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
                              color:
                                  isSelected
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
                    }).toList(),
              ),
          ],
        ),
        _buildZoomControls(),
        _buildMapControls(),
        if (!_showMarkers) _buildZoomNotification(),
        if (widget.selectedStop != null)
          _buildStopInfoCard(widget.selectedStop!),
        if (widget.isLoading) const Center(child: CircularProgressIndicator()),
      ],
    );
  }

  Widget _buildZoomControls() => Positioned(
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
  );

  Widget _buildMapControls() => Positioned(
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
        const SizedBox(height: 8),
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
  );

  Widget _buildZoomNotification() => Positioned(
    top: 100,
    left: 0,
    right: 0,
    child: Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'zoomInToSeeStops'.tr(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
    ),
  );

  Widget _buildStopInfoCard(BusStop stop) {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Card(
        elevation: 4,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      stop.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: widget.onClearSelectedStop,
                    tooltip: 'close'.tr(),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              if (stop.address != null && stop.address!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    stop.address!,
                    style: TextStyle(color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.directions, size: 18),
                    label: Text('directions'.tr()),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onPressed: widget.onDirections,
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.list, size: 18),
                    label: Text('routes'.tr()),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onPressed: () => widget.onRoutes(stop),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to animate to user location
  void animateToUser() {
    _mapCtrl.animateTo(dest: widget.userLocation, zoom: 15.0);
  }

  // Helper method to animate to a bus stop
  void animateToStop(BusStop stop) {
    _mapCtrl.animateTo(
      dest: osm.LatLng(stop.latitude, stop.longitude),
      zoom: _currentZoom < 15 ? 15 : _currentZoom,
    );
  }

  @override
  bool get wantKeepAlive => true;
}

import 'dart:async';

import 'package:busmapcantho/core/theme/app_colors.dart';
import 'package:busmapcantho/data/model/bus_location.dart';
import 'package:busmapcantho/data/model/bus_stop.dart';
import 'package:busmapcantho/gen/assets.gen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_marker_cluster_plus/flutter_map_marker_cluster_plus.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart' as osm;
import 'package:lottie/lottie.dart' as lottie;

import '../routes/app_routes.dart';
import '../screens/bus_routes/route_detail_map_screen.dart';

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

  final List<osm.LatLng> routePoints;
  final osm.LatLng? startLocation; // Added start location parameter
  final osm.LatLng? endLocation; // Added end location parameter
  final String? distanceLabel;
  final String? durationLabel;
  final List<BusLocation>? busLocations;
  final double? markerVisibilityZoomThreshold;
  final String? transportMode;
  final Map<String, dynamic>? highlightedStep;
  final void Function(LatLngBounds)? onMapMoved;
  final void Function(osm.LatLng center, bool hasGesture)?
  onPickerMapMoved; // New callback
  final BusMapController? routeScreenMapController; // Added
  final BusStop? animateToStop; // Thêm thuộc tính này
  final List<List<osm.LatLng>>? allRoutePoints;
  final int? highlightedDirection; // Add this property

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
    this.startLocation, // Add to constructor
    this.endLocation, // Add to constructor
    this.distanceLabel,
    this.durationLabel,
    this.busLocations,
    this.markerVisibilityZoomThreshold,
    this.transportMode,
    this.highlightedStep,
    this.onMapMoved,
    this.onPickerMapMoved, // Add to constructor
    this.routeScreenMapController, // Added
    this.animateToStop,
    this.allRoutePoints,
    this.highlightedDirection, // Add to constructor
  });

  @override
  State<BusMapWidget> createState() => _BusMapWidgetState();
}

class _BusMapWidgetState extends State<BusMapWidget>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  static const _canThoCenter = osm.LatLng(10.0364634, 105.7875821);
  static const _initialZoom = 13.0;
  static const double _defaultMarkerVisibilityZoomThreshold = 15.0;

  late final AnimatedMapController _mapCtrl;
  late final StreamSubscription<MapEvent> _mapEventSub;
  double _currentZoom = _initialZoom;
  bool _showMarkers = true;
  List<BusStop> _visibleStops = []; // Add list to store visible bus stops
  bool _mapReady = false; // Track if map is rendered at least once

  final _tileProvider = FMTCTileProvider(
    stores: const {'mapStore': BrowseStoreStrategy.readUpdateCreate},
  );

  double get _markerVisibilityZoomThreshold =>
      widget.markerVisibilityZoomThreshold ??
      _defaultMarkerVisibilityZoomThreshold;

  @override
  void initState() {
    super.initState();
    _mapCtrl = AnimatedMapController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _mapEventSub = _mapCtrl.mapController.mapEventStream.listen(_onMapEvent);
    _updateRouteScreenMapController(); // Added
    // Remove _updateVisibleStops() from here
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Remove _updateVisibleStops() from here
      if (widget.onMapMoved != null) {
        final bounds = _mapCtrl.mapController.camera.visibleBounds;
        widget.onMapMoved!(bounds);
      }
    });
  }

  void _onMapEvent(MapEvent evt) {
    if (evt is MapEventMove && mounted) {
      setState(() {
        _currentZoom = evt.camera.zoom;
        _showMarkers = _currentZoom >= _markerVisibilityZoomThreshold;

        // Update visible stops when map moves
        if (_showMarkers) {
          _updateVisibleStops();
        }
      });
    }
    if (evt is MapEventMoveEnd && widget.onMapMoved != null) {
      final bounds = _mapCtrl.mapController.camera.visibleBounds;
      widget.onMapMoved!(bounds);

      // Update visible stops when map stops moving
      if (_showMarkers) {
        _updateVisibleStops();
      }
    }
  }

  // Method to filter stops by current viewport
  void _updateVisibleStops() {
    final bounds = _mapCtrl.mapController.camera.visibleBounds;

    // Add buffer around visible area (about 20% extra)
    final extendedBounds = LatLngBounds(
      osm.LatLng(
        bounds.south - (bounds.north - bounds.south) * 0.2,
        bounds.west - (bounds.east - bounds.west) * 0.2,
      ),
      osm.LatLng(
        bounds.north + (bounds.north - bounds.south) * 0.2,
        bounds.east + (bounds.east - bounds.west) * 0.2,
      ),
    );

    _visibleStops =
        widget.busStops.where((stop) {
          final stopPosition = osm.LatLng(stop.latitude, stop.longitude);
          return extendedBounds.contains(stopPosition);
        }).toList();
  }

  @override
  void didUpdateWidget(BusMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update visible stops when bus stops list changes
    if (widget.busStops != oldWidget.busStops) {
      _updateVisibleStops();
    }

    if (widget.routeScreenMapController != oldWidget.routeScreenMapController) {
      _updateRouteScreenMapController(); // Added
    }

    if (widget.highlightedStep != null &&
        widget.highlightedStep != oldWidget.highlightedStep) {
      _zoomToStep(widget.highlightedStep!);
    }

    // Khi nhận animateToStop mới, animate đến vị trí stop đó
    if (widget.animateToStop != null &&
        (oldWidget.animateToStop == null ||
            widget.animateToStop!.id != oldWidget.animateToStop?.id)) {
      _mapCtrl.animateTo(
        dest: osm.LatLng(
          widget.animateToStop!.latitude,
          widget.animateToStop!.longitude,
        ),
        zoom:
            _mapCtrl.mapController.camera.zoom < 16.0
                ? 16.0
                : _mapCtrl.mapController.camera.zoom,
      );
    }
  }

  void _zoomToStep(Map<String, dynamic> step) {
    if (step['location'] != null) {
      final location = step['location'] as osm.LatLng;
      _mapCtrl.animateTo(dest: location, zoom: 17.0);
    }
  }

  @override
  void dispose() {
    _mapEventSub.cancel();
    _mapCtrl.dispose();
    super.dispose();
  }

  void _updateRouteScreenMapController() {
    if (widget.routeScreenMapController != null) {
      widget.routeScreenMapController!.animateToStop = (BusStop stop) {
        if (mounted) {
          _mapCtrl.animateTo(
            dest: osm.LatLng(stop.latitude, stop.longitude),
            zoom:
                _mapCtrl.mapController.camera.zoom < 15.0
                    ? 15.0
                    : _mapCtrl.mapController.camera.zoom,
          );
        }
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // Only update visible stops after map is ready
    if (_mapReady &&
        _visibleStops.isEmpty &&
        widget.busStops.isNotEmpty &&
        _showMarkers) {
      _updateVisibleStops();
    }

    // Mark map as ready after first build
    if (!_mapReady) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_mapReady) {
          setState(() {
            _mapReady = true;
          });
          _updateRouteScreenMapController();
          // Now safe to update visible stops
          _updateVisibleStops();
        }
      });
    }

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
                osm.LatLng(9.238, 106.29),
                osm.LatLng(10.325, 105.22),
              ),
            ),
            onTap: (_, __) {
              widget.onClearSelectedStop();
            },
            keepAlive: true,
            onMapEvent: (event) {
              _onMapEvent(event);
              if (widget.onPickerMapMoved != null && event is MapEventMoveEnd) {
                final center = _mapCtrl.mapController.camera.center;
                widget.onPickerMapMoved!(
                  osm.LatLng(center.latitude, center.longitude),
                  true,
                );
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              tileProvider: _tileProvider,
              subdomains: const ['a', 'b', 'c'],
              userAgentPackageName: 'com.busmapcantho.app',
              additionalOptions: const {
                'attribution': '© OpenStreetMap contributors',
              },
            ),
            if (widget.routePoints.isNotEmpty)
              RoutePolylineLayer(
                routePoints: widget.routePoints,
                transportMode: widget.transportMode,
              ),

            // Add markers for start and end locations
            if (widget.startLocation != null || widget.endLocation != null)
              MarkerLayer(
                markers: [
                  if (widget.startLocation != null)
                    Marker(
                      width: 40,
                      height: 40,
                      point: widget.startLocation!,
                      child: const Icon(
                        Icons.trip_origin_outlined,
                        color: Colors.blueAccent,
                        size: 32,
                      ),
                    ),
                  if (widget.endLocation != null)
                    Marker(
                      width: 40,
                      height: 40,
                      point: widget.endLocation!,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                ],
              ),
            if (widget.highlightedStep != null &&
                widget.highlightedStep!['location'] != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: widget.highlightedStep!['location'] as osm.LatLng,
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.blue,
                      size: 40,
                    ),
                  ),
                ],
              ),
            // Render all polylines, highlight the selected direction
            if (widget.allRoutePoints?.isNotEmpty ?? false)
              PolylineLayer(
                polylines: [
                  for (int i = 0; i < widget.allRoutePoints!.length; i++)
                    if (widget.allRoutePoints![i].isNotEmpty)
                      Polyline(
                        points: widget.allRoutePoints![i],
                        color:
                            (widget.highlightedDirection ?? 0) == i
                                ? AppColors.primaryLight
                                : AppColors.primaryLight.withAlpha(
                                  (0.7 * 255).toInt(),
                                ),
                        strokeWidth:
                            (widget.highlightedDirection ?? 0) == i ? 7.0 : 4.0,
                      ),
                ],
              )
            else if (widget.routePoints.isNotEmpty)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: widget.routePoints,
                    color: AppColors.primaryLight,
                    strokeWidth: 7.0,
                  ),
                ],
              ),
            if (_showMarkers)
              BusStopMarkerLayer(
                busStops: _visibleStops, // Only show visible stops
                selectedStop: widget.selectedStop,
                onStopSelected: (stop) {
                  widget.onStopSelected(stop);
                  _mapCtrl.animateTo(
                    dest: osm.LatLng(stop.latitude, stop.longitude),
                    zoom: _currentZoom < 15 ? 15 : _currentZoom,
                  );
                },
              ),
            if (widget.busLocations != null)
              BusLocationMarkerLayer(busLocations: widget.busLocations!),
            CurrentLocationLayer(),
          ],
        ),
        MapControls(
          onZoomIn: () => _mapCtrl.animateTo(zoom: _currentZoom + 1),
          onZoomOut: () => _mapCtrl.animateTo(zoom: _currentZoom - 1),
          onRefresh: widget.refreshStops,
          onCenterUser: () {
            _mapCtrl.animateTo(
              dest: widget.userLocation,
              zoom: _currentZoom < 15 ? 15 : _currentZoom,
            );
            widget.onCenterUser();
          },
        ),
        if (_currentZoom < _markerVisibilityZoomThreshold)
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(50),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'zoomInToSeeStops'.tr(),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ),
        if (widget.selectedStop != null &&
            GoRouterState.of(context).matchedLocation != AppRoutes.directions &&
            ModalRoute.of(context)?.settings.name != '/route-detail/:routeId')
          StopInfoCard(
            stop: widget.selectedStop!,
            onClose: widget.onClearSelectedStop,
            onDirections: widget.onDirections,
            onRoutes: widget.onRoutes,
            routePoints: widget.routePoints,
            distanceLabel: widget.distanceLabel,
            durationLabel: widget.durationLabel,
          ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class BusStopMarkerLayer extends StatelessWidget {
  final List<BusStop> busStops;
  final BusStop? selectedStop;
  final StopCallback onStopSelected;

  const BusStopMarkerLayer({
    super.key,
    required this.busStops,
    required this.selectedStop,
    required this.onStopSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Get current map state for adaptive rendering
    final mapCamera = MapCamera.of(context);
    final mapController = MapController.of(context);
    final currentZoom = mapCamera.zoom;

    // Create markers with different detail levels based on zoom
    final markers =
        busStops.map((stop) {
          final isSelected = selectedStop?.id == stop.id;
          final stopPoint = osm.LatLng(stop.latitude, stop.longitude);

          // Always use detailed marker for selected stop
          if (isSelected) {
            return Marker(
              width: 40,
              height: 40,
              point: stopPoint,
              child: GestureDetector(
                onTap: () => onStopSelected(stop),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue.shade300,
                  ),
                  child: Image.asset(
                    Assets.images.busStops.path,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            );
          }

          // Simplified markers for medium zoom levels
          if (currentZoom < 16) {
            return Marker(
              width: 24,
              height: 24,
              point: stopPoint,
              child: GestureDetector(
                onTap: () => onStopSelected(stop),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryMedium,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
            );
          }

          // Detailed markers for high zoom levels
          return Marker(
            width: 32,
            height: 32,
            point: stopPoint,
            child: GestureDetector(
              onTap: () => onStopSelected(stop),
              child: Image.asset(Assets.images.busStops.path),
            ),
          );
        }).toList();

    // Use marker clustering for better performance
    return MarkerClusterLayer(
      mapController: mapController,
      mapCamera: mapCamera,
      options: MarkerClusterLayerOptions(
        maxClusterRadius: 45,
        size: const Size(40, 40),
        markers: markers,
        polygonOptions: PolygonOptions(
          borderColor: AppColors.primaryMedium,
          color: AppColors.primaryLight.withAlpha(150),
        ),
        builder: (context, markers) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.primaryMedium,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                markers.length.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class BusLocationMarkerLayer extends StatelessWidget {
  final List<BusLocation> busLocations;

  const BusLocationMarkerLayer({super.key, required this.busLocations});

  @override
  Widget build(BuildContext context) {
    return MarkerLayer(
      markers:
          busLocations
              .map(
                (bus) => Marker(
                  width: 80,
                  height: 80,
                  point: osm.LatLng(bus.lat, bus.lng),
                  alignment: Alignment.topCenter,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Transform.rotate(
                      angle: (bus.bearing - 90) * osm.pi / 180,
                      alignment: Alignment.center,
                      child: lottie.Lottie.asset(
                        Assets.animations.busAnimation,
                        width: 48,
                        height: 48,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
    );
  }
}

class RoutePolylineLayer extends StatelessWidget {
  final List<osm.LatLng> routePoints;
  final String? transportMode;

  const RoutePolylineLayer({
    super.key,
    required this.routePoints,
    this.transportMode,
  });

  @override
  Widget build(BuildContext context) {
    Color routeColor;
    double strokeWidth;
    bool isDashed = false;
    switch (transportMode) {
      case 'car':
        routeColor = Colors.blue.shade700;
        strokeWidth = 4.0;
        break;
      case 'walk':
        routeColor = Colors.green.shade700;
        strokeWidth = 3.0;
        isDashed = true;
        break;
      case 'motorbike':
        routeColor = Colors.orange.shade700;
        strokeWidth = 3.5;
        break;
      case 'bus':
        routeColor = Colors.purple.shade700;
        strokeWidth = 4.5;
        isDashed = true;
        break;
      default:
        routeColor = Colors.blue.shade700;
        strokeWidth = 4.0;
    }
    return PolylineLayer(
      polylines: [
        Polyline(
          points: routePoints,
          color: routeColor,
          strokeWidth: strokeWidth,
          gradientColors:
              isDashed
                  ? null
                  : [
                    routeColor.withAlpha(75),
                    routeColor,
                    routeColor,
                    routeColor.withAlpha(75),
                  ],
          borderColor: routeColor.withAlpha(75),
          borderStrokeWidth: isDashed ? 0 : 1.5,
        ),
      ],
    );
  }
}

class MapControls extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onRefresh;
  final VoidCallback onCenterUser;
  final VoidCallback? onPrevStep;
  final VoidCallback? onNextStep;
  final bool showStepNavigation;

  const MapControls({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onRefresh,
    required this.onCenterUser,
    this.onPrevStep,
    this.onNextStep,
    this.showStepNavigation = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        if (showStepNavigation)
          Positioned(
            bottom: 16,
            right: 16,
            child: _buildStepNavigationControls(theme),
          ),
        Positioned(
          top: 16,
          right: 16,
          child: Row(
            children: [
              FloatingActionButton(
                heroTag: 'reload_stops',
                mini: true,
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                onPressed: onRefresh,
                tooltip: 'reload'.tr(),
                child: const Icon(Icons.refresh),
              ),
              const SizedBox(width: 8),
              FloatingActionButton(
                heroTag: 'my_location',
                mini: true,
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                onPressed: onCenterUser,
                tooltip: 'myLocation'.tr(),
                child: const Icon(Icons.my_location),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /*Widget _buildZoomControls() {
    return Column(
      children: [
        FloatingActionButton(
          heroTag: 'zoom_in',
          mini: true,
          onPressed: onZoomIn,
          child: const Icon(Icons.add),
        ),
        const SizedBox(height: 4),
        FloatingActionButton(
          heroTag: 'zoom_out',
          mini: true,
          onPressed: onZoomOut,
          child: const Icon(Icons.remove),
        ),
      ],
    );
  }*/

  Widget _buildStepNavigationControls(ThemeData theme) {
    return Row(
      children: [
        FloatingActionButton(
          heroTag: 'prev_step',
          mini: true,
          backgroundColor:
              onPrevStep == null
                  ? theme.disabledColor
                  : theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          onPressed: onPrevStep,
          child: const Icon(Icons.arrow_back),
        ),
        const SizedBox(width: 8),
        FloatingActionButton(
          heroTag: 'next_step',
          mini: true,
          backgroundColor:
              onNextStep == null
                  ? theme.disabledColor
                  : theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          onPressed: onNextStep,
          child: const Icon(Icons.arrow_forward),
        ),
      ],
    );
  }
}

class StopInfoCard extends StatelessWidget {
  final BusStop stop;
  final VoidCallback onClose;
  final VoidCallback onDirections;
  final StopCallback onRoutes;
  final List<osm.LatLng> routePoints;
  final String? distanceLabel;
  final String? durationLabel;

  const StopInfoCard({
    super.key,
    required this.stop,
    required this.onClose,
    required this.onDirections,
    required this.onRoutes,
    required this.routePoints,
    this.distanceLabel,
    this.durationLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      stop.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: onClose,
                    tooltip: 'close'.tr(),
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.directions, size: 18),
                      label: Text(
                        'getDirections'.tr(),
                        overflow: TextOverflow.ellipsis,
                      ),
                      onPressed: onDirections,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        textStyle: theme.textTheme.labelLarge,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.list, size: 18),
                      label: Text(
                        'routes'.tr(),
                        overflow: TextOverflow.ellipsis,
                      ),
                      onPressed: () => onRoutes(stop),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.secondary,
                        foregroundColor: theme.colorScheme.onSecondary,
                        textStyle: theme.textTheme.labelLarge,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              if (routePoints.isNotEmpty &&
                  distanceLabel != null &&
                  durationLabel != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        distanceLabel!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        durationLabel!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: onClose,
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                          textStyle: theme.textTheme.labelLarge,
                        ),
                        child: Text('close'.tr()),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

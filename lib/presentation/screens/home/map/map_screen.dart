import 'dart:async';

import 'package:busmapcantho/core/di/injection.dart';
import 'package:busmapcantho/data/repositories/bus_stop_repository.dart';
import 'package:busmapcantho/presentation/cubits/map/map_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart' as osm;

import '../../../../data/model/bus_stop.dart';
import '../../../../gen/assets.gen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  static const _canThoCenter = osm.LatLng(10.025817, 105.7470982);
  static const _initialZoom = 13.0;
  static const _markerVisibilityZoomThreshold = 13.0;

  late final AnimatedMapController _mapCtrl;
  late final StreamSubscription<MapEvent> _mapEventSubscription;

  late final MapCubit _cubit;
  final BusStopRepository _busStopRepository = getIt<BusStopRepository>();

  List<BusStop> _allStops = [];
  bool _isLoadingAllStops = false;
  double _currentZoom = _initialZoom;
  bool _shouldShowMarkers = true;

  @override
  void initState() {
    super.initState();
    _mapCtrl = AnimatedMapController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _cubit = getIt<MapCubit>()..initialize();
    _loadAllBusStops();

    _mapEventSubscription = _mapCtrl.mapController.mapEventStream.listen(
      _onMapEvent,
    );
  }

  void _onMapEvent(MapEvent mapEvent) {
    if (mapEvent is MapEventMove && mounted) {
      setState(() {
        _currentZoom = mapEvent.camera.zoom;
        _shouldShowMarkers = _currentZoom >= _markerVisibilityZoomThreshold;
      });
    }
  }

  @override
  void dispose() {
    _mapEventSubscription.cancel();
    _mapCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAllBusStops() async {
    setState(() => _isLoadingAllStops = true);
    try {
      final stops = await _busStopRepository.getAllBusStops();
      setState(() {
        _allStops = stops;
        _isLoadingAllStops = false;
      });
    } catch (e) {
      setState(() => _isLoadingAllStops = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('errorLoadingAllStops'.tr()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocConsumer<MapCubit, MapState>(
      bloc: _cubit,
      listener: (ctx, state) {
        if (state is MapError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (ctx, state) {
        final isLoading =
            (state is MapLoading || state is MapInitial) || _isLoadingAllStops;
        final selectedStop = state is MapLoaded ? state.selectedStop : null;

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
                onTap: (_, __) {
                  /*if (selectedStop != null) _cubit.deselectBusStop();*/
                },
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

                CurrentLocationLayer(
                  /*positionStream: _cubit.positionStream,*/
                  style: LocationMarkerStyle(
                    marker: const DefaultLocationMarker(
                      color: Colors.blue,
                      child: Icon(Icons.person_pin_circle, color: Colors.white),
                    ),
                    accuracyCircleColor: Colors.blue.withOpacity(0.1),
                    showAccuracyCircle: true,
                  ),
                ),

                // Marker layer for user and bus stops
                MarkerLayer(
                  markers:
                      _shouldShowMarkers
                          ? _allStops.map((stop) {
                            final isSelected = selectedStop?.id == stop.id;
                            return Marker(
                              width: isSelected ? 40 : 32,
                              height: isSelected ? 40 : 32,
                              point: osm.LatLng(stop.latitude, stop.longitude),
                              child: GestureDetector(
                                onTap: () {
                                  _cubit.selectBusStop(stop);
                                  _mapCtrl.animateTo(
                                    dest: osm.LatLng(
                                      stop.latitude,
                                      stop.longitude,
                                    ),
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
                                            ? Colors.blue.withOpacity(0.3)
                                            : Colors.transparent,
                                  ),
                                  child: Image.asset(
                                    Assets.images.busStops.path,
                                    color:
                                        isSelected
                                            ? Colors.blue.shade700
                                            : null,
                                  ),
                                ),
                              ),
                            );
                          }).toList()
                          : [],
                ),
                if (isLoading) const Center(child: CircularProgressIndicator()),
              ],
            ),
            _buildZoomControls(),
            _buildMapControls(state),
            if (!_shouldShowMarkers) _buildZoomNotification(),
            if (selectedStop != null) _buildStopInfoCard(selectedStop),
          ],
        );
      },
    );
  }

  Widget _buildZoomControls() => Positioned(
    bottom: 100,
    right: 16,
    child: Column(
      children: [
        FloatingActionButton(
          heroTag: 'zoom_in',
          mini: true,
          onPressed: () => _mapCtrl.animateTo(zoom: _currentZoom + 1),
          child: const Icon(Icons.add),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          heroTag: 'zoom_out',
          mini: true,
          onPressed: () => _mapCtrl.animateTo(zoom: _currentZoom - 1),
          child: const Icon(Icons.remove),
        ),
      ],
    ),
  );

  Widget _buildMapControls(MapState state) => Positioned(
    top: 16,
    right: 16,
    child: Column(
      children: [
        FloatingActionButton(
          heroTag: 'reload_stops',
          mini: true,
          onPressed: _loadAllBusStops,
          tooltip: 'reload'.tr(),
          child: const Icon(Icons.refresh),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          heroTag: 'my_location',
          mini: true,
          onPressed: () => {},
              /*() => _mapCtrl.animateTo(
                dest: _cubit.currentPosition ?? _canThoCenter,
                zoom: 15,
              ),*/
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
      ),
    ),
  );

  Widget _buildStopInfoCard(BusStop stop) {
    return Card(
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
                  onPressed: () => {/*_cubit.deselectBusStop()*/},
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
                  onPressed: () {},
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
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) => ElevatedButton.icon(
    icon: Icon(icon, size: 18),
    label: Text(label),
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
    onPressed: onPressed,
  );

  @override
  bool get wantKeepAlive => true;
}

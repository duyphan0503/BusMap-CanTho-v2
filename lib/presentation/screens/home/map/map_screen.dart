import 'dart:async';

import 'package:busmapcantho/core/di/injection.dart';
import 'package:busmapcantho/presentation/cubits/map/map_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../data/model/bus_stop.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with AutomaticKeepAliveClientMixin {
  static const _canThoCenter = LatLng(10.025817, 105.7470982);
  static const _initialZoom = 13.0;

  final Completer<GoogleMapController> _mapCtrl = Completer();
  late final MapCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<MapCubit>();
    _cubit.initialize();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocConsumer<MapCubit, MapState>(
      bloc: _cubit,
      listener: (ctx, state) {
        if (state is MapError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (ctx, state) {
        // Determine loading state
        final isLoading = state is MapLoading || state is MapInitial;
        
        // Determine stops and user location
        final nearbyStops = state is MapLoaded ? state.nearbyStops : <BusStop>[];
        final selectedStop = state is MapLoaded ? state.selectedStop : null;
        final currentPosition = state is MapLoaded 
            ? state.currentPosition 
            : _canThoCenter;
        
        return Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: currentPosition,
                zoom: _initialZoom,
              ),
              markers: _buildMarkers(nearbyStops, selectedStop),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onMapCreated: (ctrl) => _mapCtrl.complete(ctrl),
              cameraTargetBounds: CameraTargetBounds(
                LatLngBounds(
                  southwest: const LatLng(9.9, 105.6),
                  northeast: const LatLng(10.2, 105.9),
                ),
              ),
              minMaxZoomPreference: const MinMaxZoomPreference(10, 18),
              onTap: (_) => _cubit.clearSelectedBusStop(),
            ),
            if (isLoading) 
              const Center(child: CircularProgressIndicator()),
            
            // Floating action buttons
            Positioned(
              top: 16,
              right: 16,
              child: Column(
                children: [
                  FloatingActionButton(
                    heroTag: 'reload_stops',
                    mini: true,
                    onPressed: _cubit.refreshNearbyStops,
                    tooltip: 'reload'.tr(),
                    child: const Icon(Icons.refresh),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton(
                    heroTag: 'my_location',
                    mini: true,
                    onPressed: _moveToCurrentLocation,
                    tooltip: 'myLocation'.tr(),
                    child: const Icon(Icons.my_location),
                  ),
                ],
              ),
            ),
            
            // Show information card for selected stop
            if (selectedStop != null)
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: _buildStopInfoCard(selectedStop),
              ),
          ],
        );
      },
    );
  }
  
  Set<Marker> _buildMarkers(List<BusStop> stops, BusStop? selectedStop) {
    return stops.map((stop) {
      final isSelected = selectedStop?.id == stop.id;
      
      return Marker(
        markerId: MarkerId(stop.id),
        position: LatLng(stop.latitude, stop.longitude),
        infoWindow: InfoWindow(
          title: stop.name,
          snippet: stop.address,
        ),
        icon: isSelected 
            ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure)
            : BitmapDescriptor.defaultMarker,
        onTap: () => _cubit.selectBusStop(stop),
      );
    }).toSet();
  }
  
  Widget _buildStopInfoCard(BusStop stop) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              stop.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (stop.address != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  stop.address!,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.directions),
                  label: Text('directions'.tr()),
                  onPressed: () => _showDirectionsToStop(stop),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.list),
                  label: Text('routes'.tr()),
                  onPressed: () => _showRoutesForStop(stop),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _moveToCurrentLocation() async {
    final state = _cubit.state;
    if (state is MapLoaded) {
      final controller = await _mapCtrl.future;
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          state.currentPosition,
          15.0,
        ),
      );
    }
  }
  
  void _showDirectionsToStop(BusStop stop) {
    // TODO: Implement directions functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('showDirectionsNotImplemented'.tr())),
    );
  }
  
  void _showRoutesForStop(BusStop stop) {
    // TODO: Implement routes listing for this stop
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('showRoutesNotImplemented'.tr())),
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    // No need to close the cubit here, it's managed by the DI container
    super.dispose();
  }
}

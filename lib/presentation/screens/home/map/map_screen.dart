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
        if (state is MapFailure) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(state.message.tr()),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (ctx, state) {
        // Determine loading
        final isLoading = state is MapLoading || state is MapInitial;
        // Determine stops and user location
        final stops = state is MapLoadSuccess ? state.stops : <BusStop>[];
        return Stack(
          children: [
            GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: _canThoCenter,
                zoom: _initialZoom,
              ),
              markers:
                  stops
                      .map(
                        (stop) => Marker(
                          markerId: MarkerId(stop.id),
                          position: LatLng(stop.latitude, stop.longitude),
                          infoWindow: InfoWindow(
                            title: stop.name,
                            snippet: stop.address,
                          ),
                        ),
                      )
                      .toSet(),
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
            ),
            if (isLoading) const Center(child: CircularProgressIndicator()),
            Positioned(
              top: 16,
              right: 16,
              child: FloatingActionButton(
                heroTag: 'reload_stops',
                mini: true,
                onPressed: _cubit.initialize,
                tooltip: 'reload'.tr(),
                child: const Icon(Icons.refresh),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }
}

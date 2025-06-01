import 'dart:async';

import 'package:busmapcantho/core/di/injection.dart';
import 'package:busmapcantho/presentation/cubits/bus_stops/stop_cubit.dart';
import 'package:busmapcantho/presentation/widgets/bus_map_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart' as osm;

import '../../../core/services/notification_snackbar_service.dart';
import '../../../data/model/bus_stop.dart';
import '../../blocs/map/map_bloc.dart';
import '../../blocs/map/map_event.dart';
import '../../blocs/map/map_state.dart';
import '../../routes/app_routes.dart';

class MapScreen extends StatefulWidget {
  final bool showBackButton;
  final List<osm.LatLng> routePoints;
  final osm.LatLng? startLocation; // Add start location parameter
  final osm.LatLng? endLocation;   // Add end location parameter

  const MapScreen({
    super.key,
    this.showBackButton = false,
    this.routePoints = const [],
    this.startLocation,           // Add to constructor
    this.endLocation,             // Add to constructor
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with AutomaticKeepAliveClientMixin {
  static const _canThoCenter = osm.LatLng(10.025817, 105.7470982);
  static const _debounceDuration = Duration(milliseconds: 500);

  late final MapBloc _mapBloc;
  late final StopCubit _stopCubit;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _mapBloc = getIt<MapBloc>()..add(InitializeMap());
    _stopCubit = getIt<StopCubit>();

    // Listen to MapBloc state changes and debounce visibleBounds updates
    _mapBloc.stream.listen((mapState) {
      if (mapState is MapLoaded) {
        if (_debounceTimer?.isActive ?? false) {
          _debounceTimer?.cancel();
        }
        _debounceTimer = Timer(_debounceDuration, () {
          if (mapState.visibleBounds != null) {
            _stopCubit.fetchStopsByBounds(mapState.visibleBounds);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        MultiBlocProvider(
          providers: [
            BlocProvider.value(value: _mapBloc),
            BlocProvider.value(value: _stopCubit),
          ],
          child: BlocConsumer<MapBloc, MapState>(
            listener: (ctx, state) {
              if (state is MapError) {
                context.showErrorSnackBar(state.message);
              }
            },
            builder: (ctx, mapState) {
              return BlocBuilder<StopCubit, StopState>(
                builder: (ctx, stopState) {
                  final isLoading =
                      (mapState is MapLoading || mapState is MapInitial) ||
                      (stopState is StopLoading);
                  final selectedStop =
                      mapState is MapLoaded ? mapState.selectedStop : null;
                  final userLocation =
                      mapState is MapLoaded
                          ? mapState.currentPosition
                          : _canThoCenter;

                  // Sử dụng _visibleStops từ StopCubit
                  final stops =
                      stopState is StopLoaded
                          ? List<BusStop>.from(stopState.stops)
                          : <BusStop>[];

                  return Stack(
                    children: [
                      BusMapWidget(
                        busStops: stops,
                        isLoading: isLoading,
                        selectedStop: selectedStop,
                        userLocation: userLocation,
                        onStopSelected: (stop) => _mapBloc.add(SelectBusStop(stop)),
                        onClearSelectedStop:
                            () => _mapBloc.add(ClearSelectedBusStop()),
                        refreshStops: () {
                          if (mapState is MapLoaded) {
                            _stopCubit.fetchStopsByBounds(mapState.visibleBounds);
                          }
                        },
                        onCenterUser: () {
                          if (mapState is MapLoaded) {
                            _mapBloc.add(UpdateVisibleBounds(null));
                          }
                        },
                        onDirections: () {
                          if (selectedStop != null) {
                            context.go(AppRoutes.directions, extra: selectedStop);
                          } else {
                            context.showInfoSnackBar(
                              'selectStopToGetDirections',
                            );
                          }
                        },
                        onRoutes: (stop) {
                          context.go(AppRoutes.routeStops, extra: stop);
                        },
                        onMapMoved:
                            (bounds) => _mapBloc.add(UpdateVisibleBounds(bounds)),
                        routePoints: widget.routePoints,
                        startLocation: widget.startLocation, // Pass start location
                        endLocation: widget.endLocation,     // Pass end location
                      ),
                      if (stopState is StopError)
                        Positioned(
                          top: 16,
                          left: 16,
                          right: 16,
                          child: Material(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                stopState.message,
                                style: TextStyle(color: Colors.red.shade800),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              );
            },
          ),
        ),
        if (widget.showBackButton)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: SafeArea(
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.go(AppRoutes.home),
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

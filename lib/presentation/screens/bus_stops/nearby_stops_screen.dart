import 'package:busmapcantho/core/di/injection.dart';
import 'package:busmapcantho/data/model/bus_stop.dart';
import 'package:busmapcantho/presentation/cubits/map/map_cubit.dart';
import 'package:busmapcantho/presentation/routes/app_routes.dart';
import 'package:busmapcantho/presentation/widgets/bus_stop_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../cubits/bus_stops/stop_cubit.dart';

class NearbyStopsScreen extends StatefulWidget {
  const NearbyStopsScreen({super.key});

  @override
  State<NearbyStopsScreen> createState() => _NearbyStopsScreenState();
}

class _NearbyStopsScreenState extends State<NearbyStopsScreen> {
  final Distance _distance = const Distance();
  late final MapCubit _mapCubit;
  late final StopCubit _stopCubit;
  final double _searchRadius = 3000;

  @override
  void initState() {
    super.initState();
    _mapCubit = getIt<MapCubit>();
    _stopCubit = getIt<StopCubit>();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    final currentState = _mapCubit.state;

    if (currentState is MapLoaded) {
      _loadNearbyStops(currentState.currentPosition);
    } else if (currentState is MapInitial || currentState is MapLoading) {
      _mapCubit.initialize();
    }
  }

  void _loadNearbyStops(LatLng position) {
    _stopCubit.loadNearbyBusStops(
      position.latitude,
      position.longitude,
      radiusInMeters: _searchRadius,
    );
  }

  void _navigateToMap(BusStop stop) {
    _mapCubit.selectBusStop(stop);
    context.go(AppRoutes.map);
  }

  void _navigateToDirections(BusStop stop) {
    context.push(AppRoutes.directionsToStop, extra: stop);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Stops'), centerTitle: true),
      body: BlocListener<MapCubit, MapState>(
        bloc: _mapCubit,
        listener: (context, state) {
          if (state is MapLoaded) {
            _loadNearbyStops(state.currentPosition);
          }
        },
        child: BlocBuilder<StopCubit, StopState>(
          bloc: _stopCubit,
          builder: (context, stopsState) {
            return BlocBuilder<MapCubit, MapState>(
              bloc: _mapCubit,
              builder: (context, mapState) {
                if (mapState is MapLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (mapState is MapError) {
                  return _buildErrorView(mapState.message);
                }

                if (stopsState is StopLoading && mapState is! MapLoaded) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (stopsState is StopError) {
                  return _buildErrorView(stopsState.message);
                }

                if (stopsState is StopLoaded && mapState is MapLoaded) {
                  return _buildStopsList(
                    stopsState.stops,
                    mapState.currentPosition,
                  );
                }

                // Fallback
                return const Center(child: Text('Loading nearby stops...'));
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _initializeLocation,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildStopsList(List<BusStop> stops, LatLng userLocation) {
    if (stops.isEmpty) {
      return const Center(child: Text('No nearby stops found.'));
    }

    return RefreshIndicator(
      onRefresh: () async => _loadNearbyStops(userLocation),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        itemCount: stops.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final stop = stops[index];
          final stopLocation = LatLng(stop.latitude, stop.longitude);
          final meters =
              _distance
                  .as(LengthUnit.Meter, userLocation, stopLocation)
                  .round();

          return BusStopTile(
            stop: stop,
            distanceInMeters: meters.toDouble(),
            onTap: () {
              _navigateToMap(stop);
            },
            trailing: IconButton(
              icon: const Icon(Icons.directions_bus),
              onPressed: () {
                _navigateToDirections(stop);
              },
            ),
          );
        },
      ),
    );
  }
}

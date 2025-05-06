import 'package:busmapcantho/core/di/injection.dart';
import 'package:busmapcantho/data/model/bus_stop.dart';
import 'package:busmapcantho/presentation/cubits/map/map_cubit.dart';
import 'package:busmapcantho/presentation/widgets/bus_stop_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

class NearbyStopsScreen extends StatefulWidget {
  const NearbyStopsScreen({super.key});

  @override
  State<NearbyStopsScreen> createState() => _NearbyStopsScreenState();
}

class _NearbyStopsScreenState extends State<NearbyStopsScreen> {
  late final MapCubit _cubit;
  final Distance _distance = const Distance();

  @override
  void initState() {
    super.initState();
    _cubit = getIt<MapCubit>()..initialize();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Stops'), centerTitle: true),
      body: BlocBuilder<MapCubit, MapState>(
        builder: (context, state) {
          if (state is MapInitial || state is MapLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is MapError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    state.message,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => _cubit.initialize(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is MapLoaded) {
            final userLocation = state.currentPosition;
            final List<BusStop> stops = state.nearbyStops;

            if (stops.isEmpty) {
              return const Center(child: Text('No nearby stops found.'));
            }

            return ListView.separated(
              itemCount: stops.length,
              itemBuilder: (context, index) {
                final stop = stops[index];
                double? meters;
                final stopLocation = LatLng(stop.latitude, stop.longitude);
                meters = _distance.as(
                  LengthUnit.Meter,
                  userLocation,
                  stopLocation,
                );
                return BusStopTile(
                  stop: stop,
                  distanceInMeters: meters,
                  onTap: () => _cubit.selectBusStop(stop),
                  trailing: IconButton(
                    icon: const Icon(Icons.directions_bus),
                    onPressed: () => {}/*onShowRoutes(stop)*/,
                  ),
                );
              },
              separatorBuilder: (_, __) => const Divider(height: 1),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

import 'package:busmapcantho/core/di/injection.dart';
import 'package:busmapcantho/data/repositories/bus_stop_repository.dart';
import 'package:busmapcantho/presentation/cubits/map/map_cubit.dart';
import 'package:busmapcantho/presentation/widgets/bus_map_widget.dart';
import 'package:busmapcantho/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart' as osm;

import '../../../../data/model/bus_stop.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with AutomaticKeepAliveClientMixin {
  static const _canThoCenter = osm.LatLng(10.025817, 105.7470982);

  late final MapCubit _cubit;
  final BusStopRepository _busStopRepository = getIt<BusStopRepository>();

  List<BusStop> _allStops = [];
  bool _isLoadingAllStops = false;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<MapCubit>()..initialize();
    _loadAllBusStops();
  }

  Future<void> _loadAllBusStops() async {
    setState(() => _isLoadingAllStops = true);
    try {
      final stops = await _busStopRepository.getAllBusStops();
      if (!mounted) return;
      setState(() {
        _allStops = stops;
        _isLoadingAllStops = false;
      });
    } catch (e) {
      setState(() => _isLoadingAllStops = false);
      if (mounted) {
        NotificationService.showError('errorLoadingAllStops');
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

        // Lấy vị trí người dùng
        final userLocation =
            state is MapLoaded
                ? osm.LatLng(
                  state.currentPosition.latitude,
                  state.currentPosition.longitude,
                )
                : _canThoCenter;

        return BusMapWidget(
          busStops: _allStops,
          isLoading: isLoading,
          selectedStop: selectedStop,
          userLocation: userLocation,
          onStopSelected: (stop) => _cubit.selectBusStop(stop),
          onClearSelectedStop: () => _cubit.clearSelectedBusStop(),
          refreshStops: _loadAllBusStops,
          onCenterUser: () {
            // Có thể thêm xử lý bổ sung ở đây nếu cần
          },
          onDirections: () {
            // TODO: Implement directions functionality
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Directions not implemented yet')),
            );
          },
          onRoutes: (stop) {
            // TODO: Implement show routes functionality
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Routes not implemented yet')),
            );
          },
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
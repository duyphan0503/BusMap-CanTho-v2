import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart' as osm;

import '../../../../core/di/injection.dart';
import '../../../../data/model/bus_stop.dart';
import '../../../../services/directions_service.dart';
import '../../../cubits/map/map_cubit.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/bus_map_widget.dart';

class DirectionsMapScreen extends StatefulWidget {
  final BusStop stop;

  const DirectionsMapScreen({super.key, required this.stop});

  @override
  State<DirectionsMapScreen> createState() => _DirectionsMapScreenState();
}

class _DirectionsMapScreenState extends State<DirectionsMapScreen>
    with AutomaticKeepAliveClientMixin {
  static const _defaultCenter = osm.LatLng(10.025817, 105.7470982);

  late final MapCubit _mapCubit;
  final DirectionsService _directionsService = getIt<DirectionsService>();

  List<osm.LatLng> _routePoints = [];
  String? _distanceLabel;
  String? _durationLabel;

  @override
  void initState() {
    super.initState();
    _mapCubit = getIt<MapCubit>()..initialize();
    _mapCubit.stream.listen((state) {
      if (state is MapLoaded) {
        _fetchRoute(state);
      }
    });
  }

  Future<void> _fetchRoute(MapLoaded state) async {
    final userLoc = osm.LatLng(
      state.currentPosition.latitude,
      state.currentPosition.longitude,
    );
    final res = await _directionsService.getDirections(
      userLoc,
      osm.LatLng(widget.stop.latitude, widget.stop.longitude),
    );
    if (res == null) return;
    setState(() {
      _routePoints = res.polyline;
      _distanceLabel =
          '${(double.parse(res.distanceText) / 1000).toStringAsFixed(1)} km';
      _durationLabel = '${(double.parse(res.durationText) / 60).ceil()} min';
    });
  }

  void _clearDirections() {
    setState(() {
      _routePoints = [];
      _distanceLabel = null;
      _durationLabel = null;
    });
  }

  void _clearAndExit() {
    _clearDirections();

    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.map);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('directions'.tr()),
        leading: BackButton(onPressed: _clearAndExit),
      ),
      body: BlocBuilder<MapCubit, MapState>(
        bloc: _mapCubit,
        builder: (context, state) {
          final isLoading = state is MapLoading || state is MapInitial;
          final userLoc =
              state is MapLoaded
                  ? osm.LatLng(
                    state.currentPosition.latitude,
                    state.currentPosition.longitude,
                  )
                  : _defaultCenter;

          return BusMapWidget(
            busStops: [widget.stop],
            isLoading: isLoading,
            selectedStop: widget.stop,
            userLocation: userLoc,
            onStopSelected: (_) {},
            onClearSelectedStop: _clearAndExit,
            refreshStops: () {},
            onCenterUser: () {
              // center back to user
            },
            onDirections: () {
              // no-op
            },
            onRoutes: (_) {},
            // pass the computed route
            routePoints: _routePoints,
            distanceLabel: _distanceLabel,
            durationLabel: _durationLabel,
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

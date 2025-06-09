import 'package:busmapcantho/core/di/injection.dart';
import 'package:busmapcantho/core/services/notification_snackbar_service.dart';
import 'package:busmapcantho/core/theme/app_colors.dart';
import 'package:busmapcantho/data/model/bus_stop.dart';
import 'package:busmapcantho/presentation/routes/app_routes.dart';
import 'package:busmapcantho/presentation/widgets/bus_stop_tile.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../blocs/map/map_bloc.dart';
import '../../blocs/map/map_event.dart';
import '../../blocs/map/map_state.dart';
import '../../cubits/bus_stops/stop_cubit.dart';

class NearbyStopsScreen extends StatefulWidget {
  const NearbyStopsScreen({super.key});

  @override
  State<NearbyStopsScreen> createState() => _NearbyStopsScreenState();
}

class _NearbyStopsScreenState extends State<NearbyStopsScreen> {
  static const int _batchSize = 5;
  static const int _defaultInitialCount = 10;
  final Distance _distance = const Distance();
  final ScrollController _scrollCtrl = ScrollController();

  late final StopCubit _stopCubit;
  late final MapBloc _mapBloc;
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    _stopCubit = getIt<StopCubit>();
    _mapBloc = getIt<MapBloc>()..add(InitializeMap());
    _scrollCtrl.addListener(_onScroll);

    _mapBloc.stream.listen((state) {
      if (state is MapLoaded && _isFirstLoad) {
        _loadNearbyStops(state);
        _isFirstLoad = false;
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      _stopCubit.loadMoreNearbyBusStops(count: _batchSize);
    }
  }

  void _loadNearbyStops(MapLoaded state) {
    final userLocation = LatLng(
      state.currentPosition.latitude,
      state.currentPosition.longitude,
    );

    context.showInfoSnackBar('loadingNearbyStops'.tr());
    _stopCubit.loadNearbyBusStops(
      userLocation.latitude,
      userLocation.longitude,
      initialCount: _defaultInitialCount,
      radiusInMeters: 3000,
    );
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _navigateToMap(BusStop stop) {
    context.showInfoSnackBar('viewingStopOnMap'.tr());
    context.go(AppRoutes.map, extra: stop.id);
  }

  void _navigateToDirections(BusStop stop) {
    context.showInfoSnackBar('gettingDirections'.tr());
    context.push(AppRoutes.directions, extra: stop);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: BlocBuilder<MapBloc, MapState>(
        bloc: _mapBloc,
        builder: (context, mapState) {
          if (mapState is MapLoading || mapState is MapInitial) {
            return _buildLoadingView('gettingYourLocation'.tr());
          }

          if (mapState is MapError) {
            return _buildErrorView(
              'locationError'.tr(),
              onRetry: () => _mapBloc.add(InitializeMap()),
            );
          }

          if (mapState is MapLoaded) {
            final userLocation = LatLng(
              mapState.currentPosition.latitude,
              mapState.currentPosition.longitude,
            );

            return BlocBuilder<StopCubit, StopState>(
              bloc: _stopCubit,
              builder: (context, stopsState) {
                if (stopsState is StopLoading) {
                  return _buildLoadingView('loadingNearbyStops'.tr());
                }

                if (stopsState is StopError) {
                  return _buildErrorView(
                    stopsState.message,
                    onRetry: () => _loadNearbyStops(mapState),
                  );
                }

                if (stopsState is StopLoaded) {
                  return _buildStopsList(stopsState, userLocation);
                }

                return _buildLoadingView('loadingNearbyStops'.tr());
              },
            );
          }

          return _buildLoadingView('preparingMap'.tr());
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    return PreferredSize(
      preferredSize: const Size.fromHeight(50),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        child: SafeArea(
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: AppColors.textOnPrimary,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'nearbyStops'.tr(),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: AppColors.textOnPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingView(String message) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(message, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildErrorView(String message, {required VoidCallback onRetry}) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.error),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
            child: Text('retry'.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildStopsList(StopLoaded stopsState, LatLng userLocation) {
    final theme = Theme.of(context);
    final stops = stopsState.stops;

    if (stops.isEmpty) {
      return Center(
        child: Text(
          'noNearbyStopsFound'.tr(),
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    return RefreshIndicator(
      color: theme.colorScheme.primary,
      onRefresh: () async {
        context.showInfoSnackBar('refreshingData'.tr());
        final mapState = _mapBloc.state;
        if (mapState is MapLoaded) {
          _loadNearbyStops(mapState);
        }
      },
      child: ListView.builder(
        controller: _scrollCtrl,
        itemCount: stops.length + (stopsState.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= stops.length) {
            return stopsState.isLoadingMore
                ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryMedium,
                      ),
                    ),
                  ),
                )
                : const SizedBox.shrink();
          }

          final stop = stops[index];
          final stopLocation = LatLng(stop.latitude, stop.longitude);
          final meters =
              _distance
                  .as(LengthUnit.Meter, userLocation, stopLocation)
                  .round();

          return BusStopTile(
            stop: stop,
            distanceInMeters: meters.toDouble(),
            onTap: () => _navigateToMap(stop),
            trailing: IconButton(
              icon: const Icon(
                Icons.directions,
                color: AppColors.primaryMedium,
              ),
              tooltip: 'getDirections'.tr(),
              onPressed: () => _navigateToDirections(stop),
            ),
          );
        },
      ),
    );
  }
}

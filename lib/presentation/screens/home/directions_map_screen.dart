import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart' as osm;

import '../../../core/di/injection.dart';
import '../../../data/model/bus_stop.dart';
import '../../blocs/map/map_bloc.dart';
import '../../blocs/map/map_event.dart';
import '../../blocs/map/map_state.dart';
import '../../cubits/directions/directions_cubit.dart';
import '../../routes/app_routes.dart';
import '../../widgets/bus_map_widget.dart';
import '../../widgets/directions_bottom_sheet.dart';
import '../../widgets/route_step_preview_overlay.dart';
import '../../widgets/common/custom_app_bar.dart';

class DirectionsMapScreen extends StatefulWidget {
  final BusStop stop;

  const DirectionsMapScreen({
    super.key,
    required this.stop,
  });

  @override
  State<DirectionsMapScreen> createState() => _DirectionsMapScreenState();
}

class _DirectionsMapScreenState extends State<DirectionsMapScreen>
    with AutomaticKeepAliveClientMixin {
  static const _defaultCenter = osm.LatLng(10.025817, 105.7470982);

  late final MapBloc _mapBloc;
  late final DirectionsCubit _directionsCubit;

  String _selectedMode = 'car';

  // State for step preview
  bool _showStepPreview = false;
  int _currentStepIndex = 0;
  Map<String, dynamic>? _currentStep;

  bool _hasFetchedDirections = false;

  @override
  void initState() {
    super.initState();
    _mapBloc = getIt<MapBloc>()..add(InitializeMap());
    _directionsCubit = getIt<DirectionsCubit>();

    _mapBloc.stream.listen((state) {
      if (state is MapLoaded && !_hasFetchedDirections) {
        _fetchDirections(state);
        _hasFetchedDirections = true;
      }
    });
  }

  void _fetchDirections(MapLoaded state) {
    final userLoc = osm.LatLng(
      state.currentPosition.latitude,
      state.currentPosition.longitude,
    );

    final stopLoc = osm.LatLng(
      widget.stop.latitude,
      widget.stop.longitude,
    );

    _directionsCubit.getDirectionsForAllModes(userLoc, stopLoc);
  }

  void _clearAndExit() {
    if (_showStepPreview) {
      // If in preview mode, just exit preview
      setState(() {
        _showStepPreview = false;
      });
    } else {
      // Otherwise exit the directions screen
      _directionsCubit.clearDirections();
      context.canPop() ? context.pop() : context.go(AppRoutes.home);
    }
  }

  void _onModeChanged(String mode) {
    if (_selectedMode == mode) return;

    setState(() => _selectedMode = mode);

    if (_mapBloc.state is MapLoaded) {
      final state = _mapBloc.state as MapLoaded;
      final userLoc = osm.LatLng(
        state.currentPosition.latitude,
        state.currentPosition.longitude,
      );

      final stopLoc = osm.LatLng(
        widget.stop.latitude,
        widget.stop.longitude,
      );

      _directionsCubit.changeTransportMode(mode, userLoc, stopLoc);
    }
  }

  void _onStepSelected(int stepIndex, List<Map<String, dynamic>> steps) {
    if (stepIndex < 0 || stepIndex >= steps.length) return;

    setState(() {
      _showStepPreview = true;
      _currentStepIndex = stepIndex;
      _currentStep = steps[stepIndex];
    });
  }

  void _closeStepPreview() {
    setState(() {
      _showStepPreview = false;
    });
  }

  void _navigateToStep(int stepIndex, List<Map<String, dynamic>> steps) {
    if (stepIndex < 0 || stepIndex >= steps.length) return;

    setState(() {
      _currentStepIndex = stepIndex;
      _currentStep = steps[stepIndex];
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: CustomAppBar(
        title: _showStepPreview ? widget.stop.name : 'directions'.tr(),
        leading: BackButton(
          onPressed: _clearAndExit,
          color: theme.appBarTheme.iconTheme?.color ?? theme.colorScheme.onPrimary,
        ),
        actions: [],
        centerTitle: true,
        elevation: 0,
      ),
      body: BlocBuilder<MapBloc, MapState>(
        bloc: _mapBloc,
        builder: (context, mapState) {
          final isLoading = mapState is! MapLoaded;
          final userLoc = mapState is MapLoaded
              ? osm.LatLng(mapState.currentPosition.latitude, mapState.currentPosition.longitude)
              : _defaultCenter;

          final stopLoc = osm.LatLng(widget.stop.latitude, widget.stop.longitude);

          return BlocBuilder<DirectionsCubit, DirectionsState>(
            bloc: _directionsCubit,
            builder: (context, directionsState) {
              final durations = <String, String>{};
              final distances = <String, String>{};
              final cachedResults = _directionsCubit.getCachedResults();
              for (var mode in ['car', 'walk', 'motorbike']) {
                if (cachedResults.containsKey(mode)) {
                  final result = cachedResults[mode]!;
                  durations[mode] = result.formattedDuration;
                  distances[mode] = result.formattedDistance;
                } else {
                  durations[mode] = 'loading'.tr();
                  distances[mode] = 'loading'.tr();
                }
              }

              final List<Map<String, dynamic>> steps = directionsState is DirectionsLoaded
                  ? (directionsState.steps ?? []).map((step) => Map<String, dynamic>.from(step)).toList()
                  : [];

              Map<String, dynamic>? highlightedStep = _showStepPreview && steps.isNotEmpty && _currentStepIndex < steps.length
                  ? steps[_currentStepIndex]
                  : null;

              return Stack(
                children: [
                  // Map with bus stops and routes
                  BusMapWidget(
                    busStops: [widget.stop],
                    isLoading: isLoading || directionsState is DirectionsLoading,
                    selectedStop: widget.stop,
                    userLocation: userLoc,
                    onStopSelected: (stop) {
                      /*if (stop.id == widget.stop.id && !_showStepPreview) _clearAndExit();*/
                    },
                    onClearSelectedStop: () {},
                    refreshStops: () {},
                    onCenterUser: () {},
                    onDirections: () {},
                    onRoutes: (_) {},
                    routePoints: directionsState is DirectionsLoaded
                        ? directionsState.polylinePoints
                        : [],
                    distanceLabel: directionsState is DirectionsLoaded
                        ? directionsState.formattedDistance
                        : null,
                    durationLabel: directionsState is DirectionsLoaded
                        ? directionsState.formattedDuration
                        : null,
                    transportMode: _selectedMode,
                    markerVisibilityZoomThreshold: 10.0,
                    highlightedStep: highlightedStep,
                    onMapMoved: (bounds) => _mapBloc.add(UpdateVisibleBounds(bounds)),
                  ),

                  // Display route step preview overlay at the top when active
                  if (_showStepPreview && steps.isNotEmpty && _currentStepIndex < steps.length)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: SafeArea(
                        child: RouteStepPreviewOverlay(
                          steps: steps,
                          currentStepIndex: _currentStepIndex,
                          totalSteps: steps.length,
                          onClose: _closeStepPreview,
                          onPrevStep: _currentStepIndex > 0
                              ? () => _navigateToStep(_currentStepIndex - 1, steps)
                              : null,
                          onNextStep: _currentStepIndex < steps.length - 1
                              ? () => _navigateToStep(_currentStepIndex + 1, steps)
                              : null,
                        ),
                      ),
                    ),

                  // Display navigation controls at the bottom when in preview mode
                  if (_showStepPreview)
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Row(
                        children: [
                          FloatingActionButton(
                            heroTag: 'prev_step',
                            mini: true,
                            onPressed: _currentStepIndex > 0
                                ? () => _navigateToStep(_currentStepIndex - 1, steps)
                                : null,
                            backgroundColor: _currentStepIndex > 0
                                ? theme.colorScheme.primary
                                : theme.disabledColor,
                            foregroundColor: theme.colorScheme.onPrimary,
                            child: const Icon(Icons.arrow_back),
                          ),
                          const SizedBox(width: 8),
                          FloatingActionButton(
                            heroTag: 'next_step',
                            mini: true,
                            onPressed: _currentStepIndex < steps.length - 1
                                ? () => _navigateToStep(_currentStepIndex + 1, steps)
                                : null,
                            backgroundColor: _currentStepIndex < steps.length - 1
                                ? theme.colorScheme.primary
                                : theme.disabledColor,
                            foregroundColor: theme.colorScheme.onPrimary,
                            child: const Icon(Icons.arrow_forward),
                          ),
                        ],
                      ),
                    ),

                  // Directions bottom sheet (only visible when not in preview mode)
                  if (directionsState is DirectionsLoaded && !_showStepPreview)
                    DirectionsBottomSheet(
                      steps: steps,
                      durations: durations,
                      distances: distances,
                      selectedMode: _selectedMode,
                      onModeChanged: _onModeChanged,
                      onStepTap: (stepIndex) => _onStepSelected(stepIndex, steps),
                    ),

                  // Error message display
                  if (directionsState is DirectionsError)
                    Positioned(
                      top: 90,
                      left: 16,
                      right: 16,
                      child: Material(
                        color: theme.colorScheme.error.withAlpha(50),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            directionsState.message,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.error,
                            ),
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
    );
  }

  @override
  bool get wantKeepAlive => true;
}

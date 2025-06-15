import 'package:busmapcantho/presentation/cubits/route_finder/route_finder_cubit.dart';
import 'package:busmapcantho/presentation/cubits/route_suggestion/route_suggestion_cubit.dart';
import 'package:busmapcantho/presentation/cubits/route_suggestion/route_suggestion_state.dart';
import 'package:busmapcantho/presentation/routes/app_routes.dart';
import 'package:busmapcantho/presentation/widgets/custom_app_bar.dart';
import 'package:busmapcantho/presentation/widgets/location_input_section_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../data/model/bus_route.dart';
import '../../../gen/assets.gen.dart';

class RouteSuggestionScreen extends StatelessWidget {
  const RouteSuggestionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Gọi làm mới dữ liệu mỗi lần mở màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final routeFinderState = context.read<RouteFinderCubit>().state;
      final cubit = context.read<RouteSuggestionCubit>();
      cubit.updateRouteParameters(
        startLatLng: routeFinderState.startLatLng,
        startName: routeFinderState.startName,
        endLatLng: routeFinderState.endLatLng,
        endName: routeFinderState.endName,
      );
    });

    return Scaffold(
      appBar: CustomAppBar(
        title: 'routeSuggestionsTitle'.tr(),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'reload'.tr(),
            onPressed: () {
              final routeFinderState = context.read<RouteFinderCubit>().state;
              final cubit = context.read<RouteSuggestionCubit>();
              cubit.updateRouteParameters(
                startLatLng: routeFinderState.startLatLng,
                startName: routeFinderState.startName,
                endLatLng: routeFinderState.endLatLng,
                endName: routeFinderState.endName,
              );
            },
          ),
        ],
      ),
      body: const _RouteSuggestionView(),
    );
  }
}

class _RouteSuggestionView extends StatelessWidget {
  const _RouteSuggestionView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<RouteSuggestionCubit, RouteSuggestionState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.errorMessage != null) {
          return Center(child: Text('Error: \\${state.errorMessage}'));
        }
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LocationInputSection<RouteSuggestionCubit, RouteSuggestionState>(
                getStartName: (suggestionState) => suggestionState.startName,
                getEndName: (suggestionState) => suggestionState.endName,
                getStartInputError: (suggestionState) => false,
                getEndInputError: (suggestionState) => false,
                startIcon: Icons.trip_origin,
                endIcon: Icons.location_on,
                startIconColor: Colors.blue,
                endIconColor: Colors.red,
                startPlaceholder: 'currentLocationPlaceholder'.tr(),
                endPlaceholder: 'enterDestinationPlaceholder'.tr(),
                showSwapButton: false,
                isReadOnly: false,
                useCardWrapper: false,
              ),
              const SizedBox(height: 16.0),
              Text(
                'suitableTransport'.tr(),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              Expanded(
                child: ListView(
                  children: [
                    _buildBicycleSuggestionCard(
                      distanceInKm: state.distanceInKm,
                      context: context,
                    ),
                    _buildBusSuggestionsSection(context, state),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBusNotActiveCard(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Lottie.asset(
            Assets.animations.busNotFound,
            width: 180,
            height: 180,
            fit: BoxFit.contain,
            repeat: true,
          ),
        ),
      ),
    );
  }

  Widget _buildBicycleSuggestionCard({
    required BuildContext context,
    required double? distanceInKm,
  }) {
    // Average cycling speed: 15 km/h
    final speedKmh = 15.0;
    final distance = distanceInKm ?? 0.0;
    final durationHours = distance / speedKmh;
    final durationMinutes = (durationHours * 60).round();
    String timeText;
    if (durationMinutes < 60) {
      timeText = '$durationMinutes phút';
    } else {
      final hours = durationMinutes ~/ 60;
      final minutes = durationMinutes % 60;
      timeText = minutes > 0 ? '$hours giờ $minutes phút' : '$hours giờ';
    }
    return GestureDetector(
      onTap: () {
        /*context.push(AppRoutes.routeSuggestionDetail);*/
      },
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 8.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.directions_bike, color: Colors.green, size: 24),
                  const SizedBox(height: 4),
                  Text(
                    'bike'.tr(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.place,
                          size: 18,
                          color: Colors.blueGrey,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          distance > 0
                              ? '${distance.toStringAsFixed(2)} km'
                              : '--',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.timer, size: 18, color: Colors.orange),
                        const SizedBox(width: 6),
                        Text(
                          timeText,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBusRouteSuggestionCard(BuildContext context, BusRoute route) {
    final theme = Theme.of(context);
    // Lấy dữ liệu thực tế từ extra (nếu có)
    final String routeNumber = route.routeNumber;
    final String startStopName =
        route.extra?['startStopName'] ??
        (route.stops.isNotEmpty ? route.stops.first.stop.name : '--');
    final String endStopName = route.extra?['endStopName'] ?? '--';
    final String walkingDistance = route.extra?['walkingDistance'] ?? '--';
    final String busDistance = route.extra?['busDistance'] ?? '--';
    final String fare = route.fareInfo ?? 'busFareDefault'.tr();
    final String totalTime = route.extra?['totalTime'] ?? '--';

    return GestureDetector(
      onTap: () async {
        // Lấy danh sách các trạm của tuyến (nếu cần)
        final cubit = BlocProvider.of<RouteSuggestionCubit>(context);
        final stops = await cubit.getRouteStops(route.id);
        // Tìm startStop và endStop, đảm bảo trả về BusStop (không phải BusStop?)
        final startStop = stops.firstWhere((s) => s.name == startStopName);
        final endStop = stops.firstWhere((s) => s.name == endStopName);

        // Lấy vị trí đầu và cuối từ state
        final suggestionState =
            BlocProvider.of<RouteSuggestionCubit>(context).state;
        final startLatLng = suggestionState.startLatLng;
        final endLatLng = suggestionState.endLatLng;

        // Lấy danh sách các trạm đi qua từ startStop đến endStop (bao gồm cả hai)
        final startIdx = stops.indexWhere((s) => s.id == startStop.id);
        final endIdx = stops.indexWhere((s) => s.id == endStop.id);
        List<Map<String, dynamic>> stopsPassingBy = [];
        if (startIdx != -1 && endIdx != -1 && startIdx <= endIdx) {
          for (int i = startIdx; i <= endIdx; i++) {
            final s = stops[i];
            stopsPassingBy.add({
              'name': s.name,
              'latitude': s.latitude,
              'longitude': s.longitude,
              'isBusStop': true,
            });
          }
        }

        context.push(
          AppRoutes.routeSuggestionDetail,
          extra: {
            'route': route,
            'startStop': startStop,
            'endStop': endStop,
            'walkingDistance': walkingDistance,
            'busDistance': busDistance,
            'fare': fare,
            'totalTime': totalTime,
            'stopsPassingBy': stopsPassingBy,
            'startName': suggestionState.startName,
            'endName': suggestionState.endName,
            'startLatLng': startLatLng,
            'endLatLng': endLatLng,
          },
        );
      },
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 16.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: theme.primaryColorLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.directions_bus,
                          color: Colors.blueAccent,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          routeNumber,
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue, width: 1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          fare,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        totalTime,
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.directions_walk,
                        size: 18,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 4),
                      Text(walkingDistance),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Row(
                    children: [
                      const Icon(
                        Icons.directions_bus,
                        size: 18,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 4),
                      Text(busDistance),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'startAtStop'.tr(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      startStopName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBusSuggestionsSection(
    BuildContext context,
    RouteSuggestionState state,
  ) {
    if (!state.isBusActive || state.suggestedBusRoutes.isEmpty) {
      return _buildBusNotActiveCard(context);
    }
    return Column(
      children:
          state.suggestedBusRoutes
              .map((route) => _buildBusRouteSuggestionCard(context, route))
              .toList(),
    );
  }
}

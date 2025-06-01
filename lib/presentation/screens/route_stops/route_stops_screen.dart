import 'package:busmapcantho/core/services/notification_snackbar_service.dart';
import 'package:busmapcantho/core/theme/app_colors.dart';
import 'package:busmapcantho/data/model/bus_location.dart';
import 'package:busmapcantho/data/model/bus_route.dart';
import 'package:busmapcantho/data/model/bus_stop.dart';
import 'package:busmapcantho/presentation/cubits/favorites/favorites_cubit.dart';
import 'package:busmapcantho/presentation/cubits/notification/notification_cubit.dart';
import 'package:busmapcantho/presentation/cubits/route_stops/route_stops_cubit.dart';
import 'package:busmapcantho/presentation/widgets/bus_location_tile.dart';
import 'package:busmapcantho/presentation/widgets/option_bottom_sheet.dart';
import 'package:busmapcantho/presentation/widgets/route_card_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';

import '../../routes/app_routes.dart';

class RouteStopsScreen extends StatefulWidget {
  final BusStop stop;

  const RouteStopsScreen({super.key, required this.stop});

  @override
  State<RouteStopsScreen> createState() => _RouteStopsScreenState();
}

class _RouteStopsScreenState extends State<RouteStopsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  static const _tabBarHeight = 70.0;
  static const _bottomButtonHeight = 72.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<RouteStopsCubit>().loadRoutesForStop(widget.stop);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleBackNavigation(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  void _toggleFavoriteStatus(BuildContext context) {
    final cubit = context.read<FavoritesCubit>();
    final isFavorite = cubit.isStopFavorite(widget.stop.id);

    if (isFavorite) {
      final favoriteId = cubit.getFavoriteIdForStop(widget.stop.id);
      if (favoriteId != null) cubit.removeFavoriteStop(favoriteId);
    } else {
      cubit.addFavoriteStop(stopId: widget.stop.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: BlocBuilder<RouteStopsCubit, RouteStopsState>(
        builder: (context, state) {
          final routes =
              state is RouteStopsLoaded ? state.routes : <BusRoute>[];
          final buses =
              state is RouteStopsLoaded ? state.vehicles : <BusLocation>[];

          return Column(
            children: [
              const SizedBox(height: _tabBarHeight + 24),
              _RouteTabBar(controller: _tabController),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _RouteList(routes: routes),
                    _BusList(buses: buses),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: _buildBottomButtons(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(_tabBarHeight),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            widget.stop.name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _handleBackNavigation(context),
          ),
          actions: [_buildFavoriteButton(context)],
        ),
      ),
    );
  }

  Widget _buildFavoriteButton(BuildContext context) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      buildWhen: (previous, current) {
        return previous.favoriteStops != current.favoriteStops;
      },
      builder: (context, state) {
        final isFavorite = context.read<FavoritesCubit>().isStopFavorite(
          widget.stop.id,
        );

        return IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: Colors.redAccent,
            size: 28,
          ),
          tooltip: isFavorite ? 'removeFavorite'.tr() : 'addFavorite'.tr(),
          onPressed: () => _toggleFavoriteStatus(context),
        );
      },
    );
  }

  Widget? _buildBottomButtons(BuildContext context) {
    return BlocBuilder<RouteStopsCubit, RouteStopsState>(
      builder: (context, state) {
        if (state is! RouteStopsLoaded || state.routes.isEmpty) {
          return const SizedBox.shrink();
        }

        return SafeArea(
          minimum: const EdgeInsets.all(16),
          child: SizedBox(
            height: _bottomButtonHeight,
            child: Row(
              children: [
                _MonitorButton(routes: state.routes, stop: widget.stop),
                const SizedBox(width: 16),
                _ReportButton(routes: state.routes, stop: widget.stop),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RouteTabBar extends StatelessWidget {
  final TabController controller;

  const _RouteTabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white.withAlpha(200),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: AppColors.primaryDark,
        unselectedLabelColor: Colors.white,
        labelStyle: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        tabs: [
          Tab(text: 'routesTabPassed'.tr()),
          Tab(text: 'routesTabBusList'.tr()),
        ],
        dividerColor: Colors.transparent,
      ),
    );
  }
}

class _RouteList extends StatelessWidget {
  final List<BusRoute> routes;

  const _RouteList({required this.routes});

  @override
  Widget build(BuildContext context) {
    if (routes.isEmpty) {
      return Center(child: Text('noRoutesForStop'.tr()));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: routes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) => RouteCardWidget(route: routes[index]),
    );
  }
}

class _BusList extends StatelessWidget {
  final List<BusLocation> buses;

  const _BusList({required this.buses});

  @override
  Widget build(BuildContext context) {
    if (buses.isEmpty) {
      return Center(child: Text('noBusesForStop'.tr()));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: buses.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder:
          (context, index) => BusLocationTile(busLocation: buses[index]),
    );
  }
}

class _MonitorButton extends StatelessWidget {
  final List<BusRoute> routes;
  final BusStop stop;

  const _MonitorButton({required this.routes, required this.stop});

  void _showBottomSheet(BuildContext context) {
    const distances = [100, 500, 1000, 5000];
    final labels = ['100m', '500m', '1km', '5km'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => OptionBottomSheet(
            title: tr('monitorStopTitle', args: [stop.name]),
            subtitle: 'monitorStopSubtitle'.tr(),
            optionLabels:
                labels.map((l) => tr('monitorOptionLabel', args: [l])).toList(),
            activeColor: AppColors.primaryMedium,
            confirmText: 'monitorConfirm'.tr(),
            onConfirm:
                (index) => _handleMonitor(context, index, distances, labels),
            selectLabel: 'monitorSelectLabel'.tr(),
          ),
    );
  }

  void _handleMonitor(
    BuildContext context,
    int index,
    List<int> distances,
    List<String> labels,
  ) {
    try {
      if (!GetIt.I.isRegistered<NotificationCubit>()) {
        context.showErrorSnackBar('Notification service is not available.');
        return;
      }
      final cubit = context.read<NotificationCubit>();
      final routeId = routes.isNotEmpty ? routes.first.id : '';

      if (routeId.isEmpty) return;

      cubit.startMonitoring(
        stop: stop,
        distanceThreshold: distances[index].toDouble(),
        routeId: routeId,
      );

      context.showSuccessSnackBar(
        tr('monitorSuccessMessage', args: [labels[index]]),
      );
    } catch (e) {
      context.showErrorSnackBar('Failed to set up monitoring: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ElevatedButton.icon(
        icon: const Icon(Icons.notifications_active),
        label: Text('monitorStop'.tr()),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryMedium,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: () => _showBottomSheet(context),
      ),
    );
  }
}

class _ReportButton extends StatelessWidget {
  final List<BusRoute> routes;
  final BusStop stop;

  const _ReportButton({required this.routes, required this.stop});

  void _showBottomSheet(BuildContext context) {
    const times = [2, 5, 10, 15];
    final labels = times.map((t) => '$t ${tr('minutes')}').toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => OptionBottomSheet(
            title: tr('reportStopTitle', args: [stop.name]),
            subtitle: 'reportStopSubtitle'.tr(),
            optionLabels:
                labels.map((l) => tr('reportOptionLabel', args: [l])).toList(),
            activeColor: AppColors.secondaryDark,
            confirmText: 'reportConfirm'.tr(),
            onConfirm: (index) => _handleReport(context, index, times, labels),
            selectLabel: 'reportSelectLabel'.tr(),
          ),
    );
  }

  void _handleReport(
    BuildContext context,
    int index,
    List<int> times,
    List<String> labels,
  ) {
    try {
      if (!GetIt.I.isRegistered<NotificationCubit>()) {
        context.showErrorSnackBar('Notification service is not available.');
        return;
      }
      final cubit = context.read<NotificationCubit>();
      final routeId = routes.isNotEmpty ? routes.first.id : '';

      if (routeId.isEmpty) return;

      cubit.startReporting(
        stop: stop,
        timeThreshold: times[index],
        routeId: routeId,
      );

      context.showSuccessSnackBar(
        tr('reportSuccessMessage', args: [labels[index]]),
      );
    } catch (e) {
      context.showErrorSnackBar('Failed to set up reporting: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ElevatedButton.icon(
        icon: const Icon(Icons.directions_bus),
        label: Text('reportArrival'.tr()),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondaryDark,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: () => _showBottomSheet(context),
      ),
    );
  }
}

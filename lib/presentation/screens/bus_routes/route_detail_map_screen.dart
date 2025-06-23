import 'package:busmapcantho/core/di/injection.dart';
import 'package:busmapcantho/core/utils/operating_hours_translator.dart'; // Import the translator
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart' as osm;
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/notification_local_service.dart'; // Import dịch vụ thông báo
import '../../../core/theme/app_colors.dart';
import '../../../data/model/bus_route.dart';
import '../../../data/model/bus_stop.dart';
import '../../../domain/usecases/bus_routes/get_bus_route_by_id_usecase.dart';
import '../../cubits/bus_location/bus_location_cubit.dart';
import '../../cubits/bus_routes/routes_cubit.dart';
import '../../widgets/bus_map_widget.dart';
import '../../widgets/marquee_text.dart';
import '../../widgets/review_section.dart';

class RouteDetailMapScreen extends StatefulWidget {
  final BusRoute route;

  const RouteDetailMapScreen({super.key, required this.route});

  @override
  State<RouteDetailMapScreen> createState() => _RouteDetailMapScreenState();
}

class _RouteDetailMapScreenState extends State<RouteDetailMapScreen>
    with AutomaticKeepAliveClientMixin {
  static const _defaultCenter = osm.LatLng(10.025817, 105.7470982);

  late final BusMapController _mapController;
  final GlobalKey _mapKey = GlobalKey();

  bool _isLoading = true;
  bool _isOutbound = true;
  int _selectedTabIndex = 1;
  bool _expanded = true;
  bool _isTripModeActive = false;

  List<BusStop> _stops = [];
  List<BusStop> _outboundStops = [];
  List<BusStop> _inboundStops = [];
  BusStop? _selectedStop;

  bool _notifyApproach = false;
  bool _notifyArrival = false;
  bool _notifyDeparture = false;
  final Map<String, String> _busStatuses = {};

  @override
  void initState() {
    super.initState();
    _mapController = BusMapController();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _loadStopsAndRoute();
    await _loadNotificationSettings();
    if (!mounted) return;
    getIt<BusLocationCubit>();
    context.read<BusLocationCubit>().subscribe(widget.route.id);
  }

  Future<void> _loadStopsAndRoute() async {
    try {
      final cubit = context.read<RoutesCubit>();

      // Fetch the route with all its stops
      final detailedRoute = await getIt<GetBusRouteByIdUseCase>()(
        widget.route.id,
      );
      if (!mounted) return;

      final allStops = detailedRoute!.stops;

      // Separate stops by direction
      final outboundStops =
          allStops
              .where((routeStop) => routeStop.direction == 0)
              .map((routeStop) => routeStop.stop)
              .toList();

      final inboundStops =
          allStops
              .where((routeStop) => routeStop.direction == 1)
              .map((routeStop) => routeStop.stop)
              .toList();

      // Load route geometries that follow actual roads
      await cubit.loadRouteGeometries(widget.route.id);

      if (!mounted) return;
      setState(() {
        _outboundStops = outboundStops;
        _inboundStops = inboundStops;
        _stops = _isOutbound ? _outboundStops : _inboundStops;
        _selectedStop = _stops.isNotEmpty ? _stops.first : null;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      // Handle error appropriately
    }
  }

  // Helper to get route points, using geometries if available or falling back to straight lines
  List<List<osm.LatLng>> _getAllRoutePoints() {
    final cubit = context.read<RoutesCubit>();
    final geometries = cubit.state.routeGeometryMap[widget.route.id];

    final List<List<osm.LatLng>> allPoints = [];

    // Outbound
    if (geometries != null &&
        geometries.containsKey(0) &&
        geometries[0]!.isNotEmpty) {
      allPoints.add(
        geometries[0]!.map((p) => osm.LatLng(p.latitude, p.longitude)).toList(),
      );
    } else {
      allPoints.add(
        _outboundStops.map((s) => osm.LatLng(s.latitude, s.longitude)).toList(),
      );
    }

    // Inbound
    if (geometries != null &&
        geometries.containsKey(1) &&
        geometries[1]!.isNotEmpty) {
      allPoints.add(
        geometries[1]!.map((p) => osm.LatLng(p.latitude, p.longitude)).toList(),
      );
    } else {
      allPoints.add(
        _inboundStops.map((s) => osm.LatLng(s.latitude, s.longitude)).toList(),
      );
    }

    return allPoints;
  }

  Future<void> _loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _notifyApproach = prefs.getBool('notify_approach') ?? false;
      _notifyArrival = prefs.getBool('notify_arrival') ?? false;
      _notifyDeparture = prefs.getBool('notify_departure') ?? false;
    });
  }

  void _toggleDirection(bool outbound) {
    if (_isOutbound == outbound) return;

    setState(() {
      _isOutbound = outbound;
      _stops = outbound ? _outboundStops : _inboundStops;
      _selectedStop = _stops.isNotEmpty ? _stops.first : null;
    });

    if (_stops.isNotEmpty) {
      _animateToStop(_stops.first);
    }
  }

  void _animateToStop(BusStop stop) {
    setState(() => _selectedStop = stop);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.animateToStop?.call(stop);
    });
  }

  void _onTabChanged(int index) => setState(() => _selectedTabIndex = index);

  String shortRouteName(List<BusStop> stops, {bool outbound = true}) {
    if (stops.isEmpty) return '';
    final start = outbound ? stops.first : stops.last;
    final end = outbound ? stops.last : stops.first;
    final startName = start.name;
    final endName = end.name;
    if (startName.isNotEmpty && endName.isNotEmpty) {
      return outbound ? '$startName → $endName' : '$endName → $startName';
    }
    // Fallback: use address or coordinates if name is empty
    String label(BusStop stop) {
      if (stop.name.isNotEmpty) {
        return stop.name;
      }
      if (stop.address != null && stop.address!.isNotEmpty) {
        return stop.address!;
      }
      return '${stop.latitude.toStringAsFixed(4)},${stop.longitude.toStringAsFixed(4)}';
    }

    return outbound
        ? '${label(start)} -> ${label(end)}'
        : '${label(end)} -> ${label(start)}';
  }

  Future<void> _showNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setModalState) => NotificationSettingsDialog(
                  notifyApproach: _notifyApproach,
                  notifyArrival: _notifyArrival,
                  notifyDeparture: _notifyDeparture,
                  onApproachChanged: (value) {
                    setModalState(() => _notifyApproach = value);
                    prefs.setBool('notify_approach', value);
                  },
                  onArrivalChanged: (value) {
                    setModalState(() => _notifyArrival = value);
                    prefs.setBool('notify_arrival', value);
                  },
                  onDepartureChanged: (value) {
                    setModalState(() => _notifyDeparture = value);
                    prefs.setBool('notify_departure', value);
                  },
                  onDone: () => Navigator.pop(context),
                ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(theme),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryMedium,
                ),
              )
              : BlocConsumer<BusLocationCubit, BusLocationState>(
                listener: (context, state) => _handleBusLocationUpdate(state),
                builder:
                    (context, busLocationState) => _buildMainContent(
                      theme,
                      busLocationState: busLocationState,
                    ),
              ),
    );
  }

  void _handleBusLocationUpdate(BusLocationState state) {
    if (_selectedStop == null) return;

    final busLocations = state.busLocations.values.toList();
    final distCalc = Distance();

    for (final bus in busLocations) {
      final dist = distCalc.as(
        LengthUnit.Meter,
        osm.LatLng(bus.lat, bus.lng),
        osm.LatLng(_selectedStop!.latitude, _selectedStop!.longitude),
      );

      final prevStatus = _busStatuses[bus.vehicleId] ?? 'away';
      String newStatus = prevStatus;
      String notificationMessage = '';
      String? notificationTitle;
      String? status; // Trạng thái cho NotificationLocalService

      // Thiết lập các ngưỡng khoảng cách để xác định trạng thái xe buýt
      const double approachingThreshold =
          500; // Xe đang đến gần khi cách trạm 500m
      const double arrivedThreshold =
          100; // Xe đã đến nơi khi cách trạm dưới 100m
      const double departedThreshold =
          200; // Xe đã rời đi khi đã từng ở trạng thái arrived và cách trạm trên 200m

      // Logic cải tiến để xác định trạng thái xe buýt chính xác hơn
      if (dist <= arrivedThreshold && prevStatus != 'arrived') {
        // Chuyển từ approaching hoặc away sang arrived
        newStatus = 'arrived';
        if (_notifyArrival) {
          status = 'arrived';
          notificationTitle = 'route.busArrivedAtStopTitle'.tr();
          notificationMessage = 'route.busArrivedAtStop'.tr(
            args: [bus.vehicleId, _selectedStop!.name],
          );
        }
      } else if (prevStatus == 'arrived' && dist > departedThreshold) {
        // Chuyển từ arrived sang departed
        newStatus = 'departed';
        if (_notifyDeparture) {
          status = 'departed';
          notificationTitle = 'route.busDepartedStopTitle'.tr();
          notificationMessage = 'route.busDepartedStop'.tr(
            args: [bus.vehicleId, _selectedStop!.name],
          );
        }
      } else if (dist <= approachingThreshold &&
          dist > arrivedThreshold &&
          prevStatus == 'away') {
        // Chuyển từ away sang approaching
        newStatus = 'approaching';
        if (_notifyApproach) {
          status = 'approaching';
          notificationTitle = 'route.busApproachingStopTitle'.tr();
          notificationMessage = 'route.busApproachingStop'.tr(
            args: [bus.vehicleId, _selectedStop!.name],
          );
        }
      }

      if (newStatus != prevStatus) {
        _busStatuses[bus.vehicleId] = newStatus;
        if (_isTripModeActive &&
            status != null &&
            notificationMessage.isNotEmpty &&
            mounted) {
          // Sử dụng NotificationLocalService để hiển thị thông báo trên thanh thông báo
          final notificationService = NotificationLocalService();
          notificationService.showBusNotification(
            title: notificationTitle ?? 'BusMap',
            body: notificationMessage,
            status: status,
            payload: '${widget.route.id}|${_selectedStop!.id}|${bus.vehicleId}',
          );
        }
      }
    }
  }

  AppBar _buildAppBar(ThemeData theme) {
    return AppBar(
      automaticallyImplyLeading: true,
      elevation: 0,
      backgroundColor: theme.appBarTheme.backgroundColor ?? Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
      ),
      title: Text(
        widget.route.routeName,
        style:
            theme.appBarTheme.titleTextStyle ??
            theme.textTheme.titleLarge?.copyWith(
              color: AppColors.textOnPrimary,
            ),
      ),
      centerTitle: true,
      iconTheme: theme.appBarTheme.iconTheme,
      actions: [
        IconButton(
          icon: const Icon(
            Icons.directions_bus,
            color: AppColors.textOnPrimary,
          ),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildMainContent(
    ThemeData theme, {
    required BusLocationState busLocationState,
  }) {
    final busLocations = busLocationState.busLocations.values.toList();

    return Stack(
      children: [
        Positioned.fill(
          child: BusMapWidget(
            key: _mapKey,
            busStops: _stops,
            isLoading: _isLoading,
            selectedStop: _selectedStop,
            userLocation:
                _stops.isNotEmpty
                    ? osm.LatLng(_stops.first.latitude, _stops.first.longitude)
                    : _defaultCenter,
            onStopSelected: (stop) => setState(() => _selectedStop = stop),
            onClearSelectedStop: () => setState(() => _selectedStop = null),
            refreshStops: () => _loadStopsAndRoute(),
            onCenterUser: () {},
            onDirections: () {},
            onRoutes: (stop) {},
            allRoutePoints: _getAllRoutePoints(),
            busLocations: busLocations,
            routeScreenMapController: _mapController,
          ),
        ),
        _buildTopIndicator(theme),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildBottomPanel(theme),
        ),
        _buildNotificationButton(),
      ],
    );
  }

  Widget _buildTopIndicator(ThemeData theme) {
    return Positioned(
      top: 10,
      left: 10,
      child: ElevatedButton.icon(
        icon: Icon(
          _isTripModeActive
              ? Icons.pause_circle_filled
              : Icons.play_circle_filled,
          color: Colors.white,
          size: 18,
        ),
        label: Text(
          _isTripModeActive
              ? 'route.stopTracking'.tr()
              : 'route.startTracking'.tr(),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              _isTripModeActive ? AppColors.error : AppColors.primaryMedium,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 2,
        ),
        onPressed: () {
          setState(() {
            _isTripModeActive = !_isTripModeActive;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _isTripModeActive
                      ? 'route.tripTrackingEnabled'.tr()
                      : 'route.tripTrackingDisabled'.tr(),
                ),
                backgroundColor:
                    _isTripModeActive
                        ? AppColors.secondaryDark
                        : AppColors.primaryDark,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildBottomPanel(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRouteInfoBar(theme),
        if (_expanded) _buildExpandedPanel(theme),
      ],
    );
  }

  Widget _buildRouteInfoBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withAlpha(30),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: MarqueeText(
              text: shortRouteName(_stops, outbound: _isOutbound),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 13,
                color: AppColors.primaryDark,
              ),
              velocity: 40.0, // Adjust speed as needed
              pauseBetweenLoops: const Duration(seconds: 2),
              initialDelay: const Duration(seconds: 1),
              gapWidth: 75.0, // Adjust gap as needed
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryMedium,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            onPressed: () => _toggleDirection(!_isOutbound),
            child: Text(
              _isOutbound ? 'route.returnTrip'.tr() : 'route.outboundTrip'.tr(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => setState(() => _expanded = !_expanded),
            icon: Icon(
              _expanded ? Icons.expand_more : Icons.expand_less,
              color: AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedPanel(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withAlpha((0.05 * 255).toInt()),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      height: MediaQuery.of(context).size.height * 0.4,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: AppColors.primaryMedium,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTabItem(0, 'route.scheduleTab'.tr(), theme),
                _buildTabItem(1, 'route.stopsTab'.tr(), theme),
                _buildTabItem(2, 'route.infoTab'.tr(), theme),
                _buildTabItem(3, 'route.reviewsTab'.tr(), theme),
              ],
            ),
          ),
          Expanded(child: _buildSelectedTabContent(theme)),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String label, ThemeData theme) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => _onTabChanged(index),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? Colors.white.withAlpha((0.2 * 255).toInt())
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 12,
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedTabContent(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: switch (_selectedTabIndex) {
        0 => _buildScheduleTab(theme),
        1 => _buildStopsTab(theme),
        2 => _buildInfoTab(theme),
        3 => _buildReviewsTab(),
        _ => const SizedBox(),
      },
    );
  }

  Widget _buildScheduleTab(ThemeData theme) {
    final route = widget.route;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'route.operatingHoursTitle'.tr(),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (route.operatingHoursDescription != null &&
            route.operatingHoursDescription!.isNotEmpty)
          _buildTimeRow(
            'route.timeRange'.tr(),
            route.operatingHoursDescription!,
            theme,
          ),
        if (route.frequencyDescription != null &&
            route.frequencyDescription!.isNotEmpty)
          _buildTimeRow(
            'route.frequency'.tr(),
            route.frequencyDescription!,
            theme,
          ),
        if (route.fareInfo != null && route.fareInfo!.isNotEmpty)
          _buildTimeRow('route.fare'.tr(), route.fareInfo!, theme),
        if ((route.operatingHoursDescription == null ||
                route.operatingHoursDescription!.isEmpty) &&
            (route.frequencyDescription == null ||
                route.frequencyDescription!.isEmpty) &&
            (route.fareInfo == null || route.fareInfo!.isEmpty))
          Text('route.noScheduleInfo'.tr(), style: theme.textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildTimeRow(String label, String time, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: theme.textTheme.bodyMedium),
          ),
          // Use OperatingHoursTranslator to format the operating hours
          Text(
            OperatingHoursTranslator.translate(time), // Translate here
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStopsTab(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < _stops.length; i++)
          _buildStopItem(i, _stops[i], theme),
      ],
    );
  }

  Widget _buildStopItem(int index, BusStop stop, ThemeData theme) {
    final isSelected = _selectedStop?.id == stop.id;
    return InkWell(
      onTap: () => _animateToStop(stop),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.primaryLight.withAlpha((0.1 * 255).toInt())
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                isSelected ? AppColors.primaryMedium : AppColors.dividerColor,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? AppColors.primaryMedium
                        : AppColors.primaryDark.withAlpha((0.5 * 255).toInt()),
                shape: BoxShape.circle,
              ),
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stop.name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    stop.address ?? '',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.primaryDark.withAlpha(
                        (0.7 * 255).toInt(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTab(ThemeData theme) {
    final route = widget.route;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'route.infoTitle'.tr(),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildInfoRow('route.number'.tr(), route.routeNumber, theme),
        _buildInfoRow('route.name'.tr(), route.routeName, theme),
        if (route.description != null && route.description!.isNotEmpty)
          _buildInfoRow('route.description'.tr(), route.description!, theme),
        if (route.routeType != null && route.routeType!.isNotEmpty)
          _buildInfoRow('route.type'.tr(), route.routeType!, theme),
        if (route.agencyId != null)
          _buildInfoRow(
            'route.agency'.tr(),
            route.agencyName!, // Use agency name if available, otherwise use ID
            theme,
          ),
        _buildInfoRow('route.stopsCount'.tr(), '${_stops.length}', theme),
        _buildInfoRow(
          'route.updatedAt'.tr(),
          route.updatedAt.toString().split(' ').first,
          theme,
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.primaryDark,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    return ReviewSection(routeId: widget.route.id);
  }

  Widget _buildNotificationButton() {
    return Positioned(
      top: 80, // Changed from bottom: 80
      right: 16,
      child: FloatingActionButton(
        heroTag: 'notif_settings',
        mini: true,
        backgroundColor: AppColors.primaryMedium,
        foregroundColor: Colors.white,
        onPressed: _showNotificationSettings,
        child: const Icon(Icons.notifications),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

// Helper classes for better organization
class BusMapController {
  void Function(BusStop)? animateToStop;
}

class NotificationSettingsDialog extends StatelessWidget {
  final bool notifyApproach;
  final bool notifyArrival;
  final bool notifyDeparture;
  final ValueChanged<bool> onApproachChanged;
  final ValueChanged<bool> onArrivalChanged;
  final ValueChanged<bool> onDepartureChanged;
  final VoidCallback onDone;

  const NotificationSettingsDialog({
    super.key,
    required this.notifyApproach,
    required this.notifyArrival,
    required this.notifyDeparture,
    required this.onApproachChanged,
    required this.onArrivalChanged,
    required this.onDepartureChanged,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SwitchListTile(
            title: Text('notification.notifyApproaching'.tr()),
            value: notifyApproach,
            activeColor: AppColors.primaryMedium,
            onChanged: onApproachChanged,
          ),
          SwitchListTile(
            title: Text('notification.notifyArrival'.tr()),
            value: notifyArrival,
            activeColor: AppColors.primaryMedium,
            onChanged: onArrivalChanged,
          ),
          SwitchListTile(
            title: Text('notification.notifyDeparture'.tr()),
            value: notifyDeparture,
            activeColor: AppColors.primaryMedium,
            onChanged: onDepartureChanged,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryMedium,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            onPressed: onDone,
            child: Text('common.done'.tr()),
          ),
        ],
      ),
    );
  }
}

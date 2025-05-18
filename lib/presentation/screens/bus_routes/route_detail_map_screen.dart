import 'package:busmapcantho/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart' as osm;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:busmapcantho/core/services/notification_service.dart';
import 'package:latlong2/latlong.dart';

import '../../../data/model/bus_route.dart';
import '../../../data/model/bus_stop.dart';
import '../../cubits/bus_location/bus_location_cubit.dart';
import '../../cubits/bus_routes/routes_cubit.dart';
import '../../widgets/bus_map_widget.dart';
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

  final GlobalKey _mapKey = GlobalKey();

  bool _isLoading = true;
  bool _isOutbound = true;
  int _selectedTabIndex = 1; // Mặc định là tab "Trạm dừng" (index 1)
  bool _expanded = false;

  List<BusStop> _stops = [];
  List<osm.LatLng> _routePoints = [];
  BusStop? _selectedStop;

  bool _notifyApproach = false;
  bool _notifyArrival = false;
  bool _notifyDeparture = false;
  final Map<String, String> _busStatuses = {};

  int get _currentIndex {
    if (_selectedStop == null) return 0;
    final idx = _stops.indexWhere((s) => s.id == _selectedStop!.id);
    return idx < 0 ? 0 : idx;
  }

  @override
  void initState() {
    super.initState();
    _loadStopsAndRoute();
    getIt<BusLocationCubit>();
    context.read<BusLocationCubit>().subscribe(widget.route.id);
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        _notifyApproach = prefs.getBool('notify_approach') ?? false;
        _notifyArrival = prefs.getBool('notify_arrival') ?? false;
        _notifyDeparture = prefs.getBool('notify_departure') ?? false;
      });
    });
    NotificationService.init();
  }

  void _loadStopsAndRoute() {
    final cubit = context.read<RoutesCubit>();
    final outbound = cubit.state.routeStopsMap[widget.route.id] ?? [];
    _stops = outbound;
    if (_stops.isNotEmpty) {
      _selectedStop = _stops.first;
    }
    _routePoints =
        _stops
            .map((stop) => osm.LatLng(stop.latitude, stop.longitude))
            .toList();
    setState(() {
      _isLoading = false;
    });
  }

  void _toggleDirection(bool outbound) {
    if (_isOutbound == outbound) return;
    final cubit = context.read<RoutesCubit>();
    final stopsMap =
        outbound
            ? cubit.state.routeStopsMap[widget.route.id] ?? []
            : cubit.state.routeStopsMap[widget.route.id]?.reversed.toList() ??
                [];
    setState(() {
      _isOutbound = outbound;
      _isLoading = false;
      _stops = stopsMap;
      _routePoints =
          _stops
              .map((stop) => osm.LatLng(stop.latitude, stop.longitude))
              .toList();
      _selectedStop = _stops.isNotEmpty ? _stops.first : null;
    });
  }

  void _animateToStop(BusStop stop) {
    setState(() {
      _selectedStop = stop;
    });
  }

  void _goPrev() {
    final idx = _currentIndex;
    if (idx > 0) {
      _animateToStop(_stops[idx - 1]);
    }
  }

  void _goNext() {
    final idx = _currentIndex;
    if (idx < _stops.length - 1) {
      _animateToStop(_stops[idx + 1]);
    }
  }

  void _onTabChanged(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  String shortRouteName(List<BusStop> stops, {bool outbound = true}) {
    if (stops.isEmpty) return '';
    final start = outbound ? stops.first : stops.last;
    final end = outbound ? stops.last : stops.first;

    String extractDistrict(String? fullAddress) {
      if (fullAddress == null || fullAddress.isEmpty) return '';

      // Split address by commas and try to extract district
      final parts = fullAddress.split(',');

      // For Vietnamese addresses, district is typically the second-to-last part
      // or may contain words like "quận", "huyện", "Q.", "H."
      for (var part in parts) {
        part = part.trim();
        if (part.contains('quận') ||
            part.contains('huyện') ||
            part.contains('Q.') ||
            part.contains('H.')) {
          // Extract just the name without the district prefix
          final nameParts = part.split(' ').skip(1).join(' ');
          return nameParts.isNotEmpty ? nameParts : part;
        }
      }

      // If no district identifier found, use last part (which might be district)
      // or if there's only one part, use the whole thing
      return parts.length > 1
          ? parts[parts.length - 2].trim()
          : parts[0].trim();
    }

    String getLocationLabel(BusStop stop) {
      if (stop.address != null && stop.address!.isNotEmpty) {
        return extractDistrict(stop.address);
      }
      return '${stop.latitude.toStringAsFixed(4)},${stop.longitude.toStringAsFixed(4)}';
    }

    return '${getLocationLabel(start)} → ${getLocationLabel(end)}';
  }

  void _showNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    showModalBottomSheet(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text('Notify when approaching'),
                value: _notifyApproach,
                onChanged: (v) {
                  setModalState(() => _notifyApproach = v);
                  prefs.setBool('notify_approach', v);
                },
              ),
              SwitchListTile(
                title: const Text('Notify on arrival'),
                value: _notifyArrival,
                onChanged: (v) {
                  setModalState(() => _notifyArrival = v);
                  prefs.setBool('notify_arrival', v);
                },
              ),
              SwitchListTile(
                title: const Text('Notify on departure'),
                value: _notifyDeparture,
                onChanged: (v) {
                  setModalState(() => _notifyDeparture = v);
                  prefs.setBool('notify_departure', v);
                },
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final center =
        _stops.isNotEmpty
            ? osm.LatLng(_stops.first.latitude, _stops.first.longitude)
            : _defaultCenter;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.route.routeName),
        actions: [
          IconButton(icon: const Icon(Icons.directions_bus), onPressed: () {}),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : BlocBuilder<BusLocationCubit, BusLocationState>(
                builder: (context, busLocationState) {
                  final busLocations =
                      busLocationState.busLocations.values.toList();
                  final center =
                      _stops.isNotEmpty
                          ? osm.LatLng(
                            _stops.first.latitude,
                            _stops.first.longitude,
                          )
                          : _defaultCenter;

                  // notification logic
                  if (_selectedStop != null) {
                    final distCalc = Distance();
                    for (var bus in busLocations) {
                      final dist = distCalc.as(
                        LengthUnit.Meter,
                        osm.LatLng(bus.lat, bus.lng),
                        osm.LatLng(_selectedStop!.latitude, _selectedStop!.longitude),
                      );
                      final prev = _busStatuses[bus.vehicleId] ?? 'away';
                      if (_notifyApproach && prev == 'away' && dist <= 500 && dist > 100) {
                        NotificationService.showNotification(
                          bus.vehicleId.hashCode,
                          'Bus Approaching',
                          'Bus ${bus.vehicleId} is ${dist.toStringAsFixed(0)}m away',
                        );
                        _busStatuses[bus.vehicleId] = 'approached';
                      }
                      if (_notifyArrival && prev != 'arrived' && dist <= 100) {
                        NotificationService.showNotification(
                          bus.vehicleId.hashCode,
                          'Bus Arrived',
                          'Bus ${bus.vehicleId} has arrived',
                        );
                        _busStatuses[bus.vehicleId] = 'arrived';
                      }
                      if (_notifyDeparture && prev == 'arrived' && dist > 100) {
                        NotificationService.showNotification(
                          bus.vehicleId.hashCode + 1,
                          'Bus Departing',
                          'Bus ${bus.vehicleId} is departing',
                        );
                        _busStatuses[bus.vehicleId] = 'departed';
                      }
                    }
                  }

                  return Stack(
                    children: [
                      Positioned.fill(
                        child: BusMapWidget(
                          key: _mapKey,
                          busStops: _stops,
                          isLoading: false,
                          selectedStop: _selectedStop,
                          userLocation: center,
                          onStopSelected: (stop) {
                            setState(() {
                              _selectedStop = stop;
                            });
                          },
                          onClearSelectedStop: () {
                            setState(() {
                              _selectedStop = null;
                            });
                          },
                          refreshStops: () {},
                          onCenterUser: () {},
                          onDirections: () {},
                          onRoutes: (_) {},
                          routePoints: _routePoints,
                          distanceLabel: null,
                          durationLabel: null,
                          busLocations: busLocations, // Truyền vào đây
                        ),
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Text('Bắt đầu khởi hành'),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black38,
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      shortRouteName(
                                        _stops,
                                        outbound: _isOutbound,
                                      ),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade700,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Spacer(),
                                  ElevatedButton(
                                    onPressed:
                                        () => _toggleDirection(!_isOutbound),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                    ),
                                    child: Text(
                                      _isOutbound ? 'Lượt về' : 'Lượt đi',
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _expanded = !_expanded;
                                      });
                                    },
                                    icon: Icon(
                                      _expanded
                                          ? Icons.expand_less
                                          : Icons.expand_more,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_expanded)
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 5,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                height:
                                    MediaQuery.of(context).size.height * 0.4,
                                child: Column(
                                  children: [
                                    // Tab bar
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      color: Theme.of(context).primaryColor,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          _buildTabItem(0, 'Biểu đồ'),
                                          _buildTabItem(1, 'Trạm dừng'),
                                          _buildTabItem(2, 'Thông tin'),
                                          _buildTabItem(3, 'Đánh giá'),
                                        ],
                                      ),
                                    ),

                                    // Tab content with scroll view
                                    Expanded(
                                      child: SingleChildScrollView(
                                        padding: const EdgeInsets.all(16),
                                        child:
                                            _selectedTabIndex == 0
                                                ? _buildScheduleTab()
                                                : _selectedTabIndex == 1
                                                ? _buildStopsTab()
                                                : _selectedTabIndex == 2
                                                ? _buildInfoTab()
                                                : _buildReviewsTab(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      // notification settings button
                      Positioned(
                        bottom: 80,
                        right: 16,
                        child: FloatingActionButton(
                          heroTag: 'notif_settings',
                          mini: true,
                          onPressed: _showNotificationSettings,
                          child: const Icon(Icons.notifications),
                        ),
                      ),
                    ],
                  );
                },
              ),
    );
  }

  Widget _buildTabItem(int index, String label) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => _onTabChanged(index),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color:
                isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
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

  Widget _buildScheduleTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Operating Hours',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        // Replace with actual schedule data
        _buildTimeRow('Weekdays', '06:00 - 20:00'),
        _buildTimeRow('Weekends', '07:00 - 19:00'),
        _buildTimeRow('Frequency', 'Every 15-20 minutes'),
      ],
    );
  }

  Widget _buildTimeRow(String label, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label)),
          Text(time, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildStopsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < _stops.length; i++) _buildStopItem(i, _stops[i]),
      ],
    );
  }

  Widget _buildStopItem(int index, BusStop stop) {
    final isSelected = _selectedStop?.id == stop.id;
    return InkWell(
      onTap: () => _animateToStop(stop),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.grey.shade500,
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
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '${stop.address}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Route Information',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildInfoRow('Route Number', widget.route.routeNumber),
        _buildInfoRow('Total Distance', 'N/A'),
        _buildInfoRow('Travel Time', 'N/A'),
        _buildInfoRow('Stops', '${_stops.length} stops'),
        // Add more route information as needed
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: TextStyle(color: Colors.grey.shade700)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    return ReviewSection(routeId: widget.route.id);
  }

  @override
  bool get wantKeepAlive => true;
}

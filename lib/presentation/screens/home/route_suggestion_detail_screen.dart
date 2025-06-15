import 'dart:async';

import 'package:busmapcantho/core/di/injection.dart';
import 'package:busmapcantho/core/services/notification_snackbar_service.dart';
import 'package:busmapcantho/core/services/osrm_service.dart';
import 'package:busmapcantho/core/theme/app_colors.dart';
import 'package:busmapcantho/core/utils/string_utils.dart';
import 'package:busmapcantho/data/model/bus_stop.dart';
import 'package:busmapcantho/gen/assets.gen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class RouteSuggestionDetailScreen extends StatelessWidget {
  final dynamic busRoute;
  final List<dynamic>? stopsPassingBy;
  final String? startName;
  final String? endName;
  final LatLng? startLatLng; // Thêm tọa độ điểm đầu
  final LatLng? endLatLng; // Thêm tọa độ điểm cuối

  const RouteSuggestionDetailScreen({
    super.key,
    this.busRoute,
    this.stopsPassingBy,
    this.startName,
    this.endName,
    this.startLatLng,
    this.endLatLng,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? extra =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
        (ModalRoute.of(context)?.settings.arguments is Map<String, dynamic>
            ? ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>
            : null);

    final List<dynamic>? stops =
        stopsPassingBy ??
        (extra != null && extra['stopsPassingBy'] != null
            ? extra['stopsPassingBy'] as List<dynamic>
            : null);

    final String? start =
        startName ??
        (extra != null && extra['startName'] != null
            ? extra['startName'] as String
            : null);
    final String? end =
        endName ??
        (extra != null && extra['endName'] != null
            ? extra['endName'] as String
            : null);

    final LatLng? startPos = startLatLng ?? (extra?['startLatLng'] as LatLng?);
    final LatLng? endPos = endLatLng ?? (extra?['endLatLng'] as LatLng?);

    return RouteSuggestionStepOverlay(
      busRoute: busRoute,
      stopsPassingBy: stops,
      startName: start,
      endName: end,
      startLatLng: startPos,
      endLatLng: endPos,
    );
  }
}

// Widget chính cho giao diện chỉ đường
class RouteSuggestionStepOverlay extends StatefulWidget {
  final dynamic busRoute;
  final List<dynamic>? stopsPassingBy;
  final String? startName;
  final String? endName;
  final LatLng? startLatLng;
  final LatLng? endLatLng;

  const RouteSuggestionStepOverlay({
    super.key,
    this.busRoute,
    this.stopsPassingBy,
    this.startName,
    this.endName,
    this.startLatLng,
    this.endLatLng,
  });

  @override
  State<RouteSuggestionStepOverlay> createState() =>
      _RouteSuggestionStepOverlayState();
}

class _RouteSuggestionStepOverlayState extends State<RouteSuggestionStepOverlay>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final MapController _mapController = MapController();
  late final OsrmService _osrmService;

  // Biến lưu trữ thông tin đường đi bộ
  List<LatLng> _walkingRouteToFirstStop = [];
  List<LatLng> _walkingRouteFromLastStop = [];
  List<LatLng> _busRoute = [];
  bool _isLoadingRoutes = true;

  // Biến lưu trữ trạm đang được chọn trong timeline
  int _selectedTimelineIndex = -1;

  // --- Navigation mode state ---
  bool _isNavigating = false;
  int _currentStepIndex = 0;
  List<Map<String, dynamic>> _navigationSteps = [];
  StreamSubscription<Position>? _positionStream;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _osrmService = getIt<OsrmService>();

    // Tải dữ liệu đường đi khi widget được khởi tạo
    _loadRoutes();
  }

  // Phương thức tải dữ liệu đường đi
  Future<void> _loadRoutes() async {
    setState(() {
      _isLoadingRoutes = true;
    });

    final startPos = widget.startLatLng;
    final endPos = widget.endLatLng;
    final List<dynamic> stopsData = widget.stopsPassingBy ?? [];

    if (stopsData.isNotEmpty && startPos != null && endPos != null) {
      // Lấy trạm đầu tiên và cuối cùng
      final firstBusStopLatLng = LatLng(
        stopsData.first['latitude'],
        stopsData.first['longitude'],
      );
      final lastBusStopLatLng = LatLng(
        stopsData.last['latitude'],
        stopsData.last['longitude'],
      );

      // Tạo đường đi bộ từ điểm xuất phát đến trạm đầu tiên
      final walkingToFirstStop = await _osrmService.getDirections(
        startPos,
        firstBusStopLatLng,
        mode: 'walk',
      );

      // Tạo đường đi bộ từ trạm cuối cùng đến điểm đích
      final walkingFromLastStop = await _osrmService.getDirections(
        lastBusStopLatLng,
        endPos,
        mode: 'walk',
      );

      // Cập nhật dữ liệu đường đi
      if (mounted) {
        setState(() {
          _walkingRouteToFirstStop = walkingToFirstStop?.polyline ?? [];
          _walkingRouteFromLastStop = walkingFromLastStop?.polyline ?? [];

          // Tạo đường đi của xe buýt bằng cách kết nối các trạm
          _busRoute =
              stopsData
                  .map<LatLng>(
                    (stop) => LatLng(stop['latitude'], stop['longitude']),
                  )
                  .toList();

          _isLoadingRoutes = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoadingRoutes = false;
        });
      }
    }
  }

  // Phương thức để xử lý việc chọn một trạm trên timeline
  void _selectTimelineStop(
    int index,
    List<Map<String, dynamic>> timelineStops,
  ) {
    if (index < 0 || index >= timelineStops.length) return;

    final stop = timelineStops[index];
    // Kiểm tra trạm có tọa độ không
    if (stop['latitude'] == null || stop['longitude'] == null) return;

    // Cập nhật trạm đang chọn
    setState(() {
      _selectedTimelineIndex = index;
    });

    // Di chuyển bản đồ đến vị trí của trạm
    _mapController.move(
      LatLng(stop['latitude'], stop['longitude']),
      _mapController.camera.zoom < 15.0 ? 15.0 : _mapController.camera.zoom,
    );
    // Hiệu ứng marker được chọn: trigger rebuild để marker hiển thị hiệu ứng
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    _mapController.dispose();
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: _buildAppBar(),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Phần bản đồ ở nền
            _buildMap(),
            // Always show the button to get user location
            Positioned(
              top: 24,
              right: 24,
              child: FloatingActionButton(
                heroTag: 'my_location',
                mini: true,
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                onPressed: () async {
                  bool isMounted = mounted;
                  try {
                    final pos = await Geolocator.getCurrentPosition();
                    final userLatLng = LatLng(pos.latitude, pos.longitude);
                    _mapController.move(userLatLng, 17.0);
                  } catch (e) {
                    if (isMounted) {
                      if (context.mounted) {
                        context.showErrorSnackBar('locationError'.tr());
                      }
                    }
                  }
                },
                tooltip: 'myLocation'.tr(),
                child: const Icon(Icons.my_location),
              ),
            ),
            Column(
              children: [
                // Thanh thông tin điểm đi/đến ở trên
                // Nút "Bắt đầu dẫn đường"
                _buildStartNavigationButton(),
              ],
            ),
            // Hiển thị card chỉ đường nhỏ gọn ở dưới cùng khi đang dẫn đường
            if (_isNavigating)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildCompactNavigationStepCard(context),
              ),
            if (!_isNavigating) _buildDraggableSheet(),
          ],
        ),
      ),
    );
  }

  void _moveToStep(int stepIndex) {
    if (stepIndex < 0 || stepIndex >= _navigationSteps.length) return;
    setState(() {
      _currentStepIndex = stepIndex;
    });
    _moveMapToStep(stepIndex, animated: true);
  }

  void _moveMapToStep(int stepIndex, {bool animated = false}) {
    if (stepIndex < 0 || stepIndex >= _navigationSteps.length) return;
    final step = _navigationSteps[stepIndex];
    final LatLng? loc = step['location'] as LatLng?;
    if (loc != null) {
      if (animated) {
        _mapController.move(loc, 17.0, id: 'step');
      } else {
        _mapController.move(loc, 17.0);
      }
    }
  }

  // Widget hiển thị bản đồ
  Widget _buildMap() {
    // Lấy các điểm tọa độ
    final startPos = widget.startLatLng;
    final endPos = widget.endLatLng;
    final List<dynamic> stopsData = widget.stopsPassingBy ?? [];

    // Chuyển đổi stopsData thành danh sách BusStop để hiển thị trên bản đồ
    List<BusStop> busStops = [];
    for (final stop in stopsData) {
      // Chỉ thêm vào nếu là trạm xe buýt và có tọa độ
      if (stop['isBusStop'] == true &&
          stop['latitude'] != null &&
          stop['longitude'] != null) {
        busStops.add(
          BusStop(
            id: stop['id'] ?? 'stop-${busStops.length}',
            name: stop['name'] ?? '',
            latitude: stop['latitude'],
            longitude: stop['longitude'],
            address: stop['address'],
            stopCode: stop['stopCode'],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            distanceMeters: stop['distanceMeters'],
          ),
        );
      }
    }

    // Tạo danh sách tất cả các đường đi (bao gồm đường đi bộ và đường xe buýt)
    List<LatLng> allRoutePoints = [];

    // Nếu có tọa độ đường đi bộ đến trạm đầu tiên, thêm vào trước
    if (_walkingRouteToFirstStop.isNotEmpty) {
      allRoutePoints.addAll(_walkingRouteToFirstStop);
    } else if (startPos != null && stopsData.isNotEmpty) {
      // Thêm một đường thẳng từ điểm bắt đầu đến trạm đầu tiên nếu không có đường đi bộ
      allRoutePoints.add(startPos);
      allRoutePoints.add(
        LatLng(stopsData.first['latitude'], stopsData.first['longitude']),
      );
    }

    // Thêm các điểm của tuyến xe buýt
    if (_busRoute.isNotEmpty) {
      allRoutePoints.addAll(_busRoute);
    } else {
      // Tạo đường đi của xe buýt từ các trạm nếu chưa có
      for (final stop in stopsData) {
        if (stop['latitude'] != null && stop['longitude'] != null) {
          allRoutePoints.add(LatLng(stop['latitude'], stop['longitude']));
        }
      }
    }

    // Nếu có tọa độ đường đi bộ từ trạm cuối đến điểm đích, thêm vào sau
    if (_walkingRouteFromLastStop.isNotEmpty) {
      allRoutePoints.addAll(_walkingRouteFromLastStop);
    } else if (endPos != null && stopsData.isNotEmpty) {
      // Thêm một đường thẳng từ trạm cuối đến điểm đích nếu không có đường đi bộ
      allRoutePoints.add(
        LatLng(stopsData.last['latitude'], stopsData.last['longitude']),
      );
      allRoutePoints.add(endPos);
    }

    // Tạo các polyline riêng biệt để hiển thị trên bản đồ
    List<Polyline> routePolylines = [];

    // Thêm polyline cho đường đi bộ đến trạm đầu tiên
    if (_walkingRouteToFirstStop.isNotEmpty) {
      routePolylines.add(
        Polyline(
          points: _walkingRouteToFirstStop,
          color: Colors.blue,
          strokeWidth: 4.0,
          pattern: StrokePattern.dashed(segments: [6, 6]),
        ),
      );
    }

    // Thêm polyline cho đường xe buýt (giữa các trạm) với màu xanh lá và to hơn
    if (_busRoute.isNotEmpty) {
      routePolylines.add(
        Polyline(
          points: _busRoute,
          color: AppColors.primaryLight,
          strokeWidth: 7.0,
        ),
      );
    }

    // Thêm polyline cho đường đi bộ từ trạm cuối đến điểm đích
    if (_walkingRouteFromLastStop.isNotEmpty) {
      routePolylines.add(
        Polyline(
          points: _walkingRouteFromLastStop,
          color: Colors.blue,
          strokeWidth: 4.0,
          pattern: StrokePattern.dashed(segments: [6, 6]),
        ),
      );
    }

    return Stack(
      children: [
        // Sử dụng một FlutterMap duy nhất với nhiều layer
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: startPos ?? const LatLng(10.03, 105.77),
            initialZoom: 15,
          ),
          children: [
            // Tile Layer (base map)
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            ),

            // Polyline Layer cho tất cả các đường đi
            PolylineLayer(polylines: routePolylines),

            // Marker Layer cho các trạm
            MarkerLayer(
              markers: [
                // Điểm bắt đầu
                if (startPos != null)
                  Marker(
                    width: 40,
                    height: 40,
                    point: startPos,
                    child: const Icon(
                      Icons.trip_origin_outlined,
                      color: Colors.blueAccent,
                      size: 32,
                    ),
                  ),

                // Điểm kết thúc
                if (endPos != null)
                  Marker(
                    width: 40,
                    height: 40,
                    point: endPos,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),

                // Bus stops markers with selection effect
                ...busStops.asMap().entries.map((entry) {
                  final i = entry.key;
                  final stop = entry.value;
                  final isSelected =
                      _selectedTimelineIndex > 0 &&
                      i ==
                          _selectedTimelineIndex -
                              1; // offset by 1 due to start point
                  return Marker(
                    width: isSelected ? 44 : 32,
                    height: isSelected ? 44 : 32,
                    point: LatLng(stop.latitude, stop.longitude),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow:
                            isSelected
                                ? [
                                  BoxShadow(
                                    color: Colors.blue.withAlpha(
                                      (0.4 * 255).toInt(),
                                    ),
                                    blurRadius: 12,
                                  ),
                                ]
                                : [],
                      ),
                      child: Image.asset(
                        Assets.images.busStops.path,
                        color: isSelected ? Colors.blue : null,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ],
        ),

        // Hiển thị indicator khi đang tải dữ liệu
        if (_isLoadingRoutes) const Center(child: CircularProgressIndicator()),
      ],
    );
  }

  // Widget cho thanh thông tin trên cùng
  Widget _buildAppBar() {
    final startName = StringUtils.getShortName(widget.startName);
    final endName = StringUtils.getShortName(widget.endName);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isNavigating ? 'Đang dẫn đường' : 'Đi từ $startName',
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.secondaryHeaderColor,
            ),
          ),
          if (!_isNavigating)
            Text(
              'Đến $endName',
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.secondaryHeaderColor,
              ),
            ),
        ],
      ),
    );
  }

  // Widget cho nút "Bắt đầu dẫn đường"
  Widget _buildStartNavigationButton() {
    final isActive = _isNavigating;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ElevatedButton.icon(
        icon: Icon(
          isActive ? Icons.stop_circle : Icons.navigation_outlined,
          color: Colors.white,
        ),
        label: Text(
          isActive ? 'Dừng dẫn đường' : 'Bắt đầu dẫn đường',
          style: const TextStyle(color: Colors.white),
        ),
        onPressed: _onNavigationButtonPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? Colors.red : Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
    );
  }

  void _onNavigationButtonPressed() async {
    if (_isNavigating) {
      // Stop navigation
      setState(() {
        _isNavigating = false;
      });
      _positionStream?.cancel();
    } else {
      // Start navigation
      final steps = _buildNavigationSteps();
      setState(() {
        _isNavigating = true;
        _currentStepIndex = 0;
        _navigationSteps = steps;
      });
      _moveMapToStep(0);
      // Listen to user location
      _positionStream?.cancel();
      _positionStream = Geolocator.getPositionStream().listen(
        _onUserPositionUpdate,
      );
    }
  }

  List<Map<String, dynamic>> _buildNavigationSteps() {
    // Build steps: đi bộ đến trạm đầu, đi xe buýt, đi bộ đến đích
    final startName = StringUtils.getShortName(widget.startName);
    final endName = StringUtils.getShortName(widget.endName);
    final stops = widget.stopsPassingBy ?? [];
    final firstStop = stops.isNotEmpty ? (stops.first['name'] ?? '') : '';
    final lastStop = stops.isNotEmpty ? (stops.last['name'] ?? '') : '';
    final routeNumber = widget.busRoute?.routeNumber ?? '';
    final routeName = widget.busRoute?.routeName ?? '';
    final fare = widget.busRoute?.fareInfo ?? '';
    final walkingDistance = widget.busRoute?.extra?['walkingDistance'] ?? '';
    final busDistance = widget.busRoute?.extra?['busDistance'] ?? '';
    final endWalkingDistance =
        widget.busRoute?.extra?['endWalkingDistance'] ?? '400m';
    final walkingTime = widget.busRoute?.extra?['walkingTime'] ?? '';
    final busTime = widget.busRoute?.extra?['busTime'] ?? '';
    final endWalkingTime = widget.busRoute?.extra?['endWalkingTime'] ?? '';
    return [
      {
        'icon': Icons.directions_walk,
        'title': 'Đi đến trạm $firstStop',
        'subtitle': 'Xuất phát từ [ $startName ]',
        'duration': walkingTime,
        'distance': walkingDistance,
        'location': widget.startLatLng,
      },
      {
        'icon': Icons.directions_bus,
        'title': 'Đi tuyến $routeNumber: $routeName',
        'subtitle': '$firstStop → $lastStop',
        'duration': busTime,
        'distance': busDistance,
        'price': fare,
        'location':
            stops.isNotEmpty
                ? LatLng(stops.first['latitude'], stops.first['longitude'])
                : null,
      },
      {
        'icon': Icons.directions_walk,
        'title': 'Xuống tại trạm $lastStop và đi tới điểm đến',
        'subtitle': 'Đi đến [ $endName ]',
        'duration': endWalkingTime,
        'distance': endWalkingDistance,
        'location': widget.endLatLng,
      },
    ];
  }

  void _onUserPositionUpdate(Position pos) {
    // Auto-advance if near next step
    if (_isNavigating && _currentStepIndex < _navigationSteps.length - 1) {
      final nextStep = _navigationSteps[_currentStepIndex + 1];
      final LatLng? nextLoc = nextStep['location'] as LatLng?;
      if (nextLoc != null) {
        final dist = Geolocator.distanceBetween(
          pos.latitude,
          pos.longitude,
          nextLoc.latitude,
          nextLoc.longitude,
        );
        if (dist < 50) {
          _moveToStep(_currentStepIndex + 1);
        }
      }
    }
  }

  // Widget cho bảng thông tin có thể kéo
  Widget _buildDraggableSheet() {
    final routeNumber = widget.busRoute?.routeNumber ?? '...';
    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.2,
      maxChildSize: 0.85,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(color: Colors.black.withAlpha(50), blurRadius: 10),
            ],
          ),
          child: Column(
            children: [
              // Thanh ngang nhỏ để kéo
              Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              // Header của bảng
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.directions_bus, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            routeNumber,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.swap_vert, color: Colors.grey),
                  ],
                ),
              ),
              // Thanh Tab
              TabBar(
                controller: _tabController,
                labelColor: Colors.green,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.green,
                tabs: const [
                  Tab(text: 'CHI TIẾT CÁCH ĐI'),
                  Tab(text: 'CÁC TRẠM ĐI QUA'),
                ],
              ),
              // Nội dung của các Tab
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Chi tiết cách đi
                    ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16.0),
                      children: _buildStepDetailCards(),
                    ),
                    // Tab 2: Các trạm đi qua
                    _buildStopsPassingByTimeline(scrollController),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Hiển thị các bước hướng dẫn dựa trên dữ liệu thực
  List<Widget> _buildStepDetailCards() {
    final startName = StringUtils.getShortName(widget.startName);
    final endName = StringUtils.getShortName(widget.endName);
    final stops = widget.stopsPassingBy ?? [];
    final firstStop = stops.isNotEmpty ? (stops.first['name'] ?? '') : '';
    final lastStop = stops.isNotEmpty ? (stops.last['name'] ?? '') : '';
    final routeNumber = widget.busRoute?.routeNumber ?? '';
    final routeName = widget.busRoute?.routeName ?? '';
    final fare = widget.busRoute?.fareInfo ?? '';

    // Lấy khoảng cách các đoạn đường
    final walkingDistance = widget.busRoute?.extra?['walkingDistance'] ?? '';
    final busDistance = widget.busRoute?.extra?['busDistance'] ?? '';
    final endWalkingDistance =
        widget.busRoute?.extra?['endWalkingDistance'] ?? '400m';

    // Lấy thời gian các đoạn đường (đã được tính toán từ cubit)
    final walkingTime = widget.busRoute?.extra?['walkingTime'] ?? '';
    final busTime = widget.busRoute?.extra?['busTime'] ?? '';
    final endWalkingTime = widget.busRoute?.extra?['endWalkingTime'] ?? '';

    return [
      GestureDetector(
        onTap: () {
          // Di chuyển map đến điểm đầu
          if (widget.startLatLng != null) {
            _mapController.move(widget.startLatLng!, 17.0);
          }
        },
        child: _buildStepDetailCard(
          icon: Icons.directions_walk,
          title: 'Đi đến trạm $firstStop',
          subtitle: 'Xuất phát từ [ $startName ]',
          duration: walkingTime,
          distance: walkingDistance,
        ),
      ),
      GestureDetector(
        onTap: () {
          // Zoom map to fit the bus route
          if (_busRoute.isNotEmpty) {
            var bounds = LatLngBounds(_busRoute.first, _busRoute.first);
            for (final point in _busRoute) {
              bounds.extend(point);
            }
            // For flutter_map >= 4.0.0, use camera.fitBounds
            _mapController.fitCamera(
              CameraFit.bounds(
                bounds: bounds,
                padding: const EdgeInsets.all(60),
              ),
            );
          }
        },
        child: _buildStepDetailCard(
          icon: Icons.directions_bus,
          title: 'Đi tuyến $routeNumber: $routeName',
          subtitle: '$firstStop → $lastStop',
          duration: busTime,
          distance: busDistance,
          price: fare,
        ),
      ),
      GestureDetector(
        onTap: () {
          // Di chuyển map đến điểm cuối
          if (widget.endLatLng != null) {
            _mapController.move(widget.endLatLng!, 17.0);
          }
        },
        child: _buildStepDetailCard(
          icon: Icons.directions_walk,
          title: 'Xuống tại trạm $lastStop và đi tới điểm đến',
          subtitle: 'Đi đến [ $endName ]',
          duration: endWalkingTime,
          distance: endWalkingDistance,
        ),
      ),
    ];
  }

  // Widget cho tab "CÁC TRẠM ĐI QUA"
  Widget _buildStopsPassingByTimeline(ScrollController scrollController) {
    final stops = widget.stopsPassingBy;
    final startName = StringUtils.getShortName(widget.startName);
    final endName = StringUtils.getShortName(widget.endName);
    final startLatLng = widget.startLatLng;
    final endLatLng = widget.endLatLng;

    if (stops == null || stops.isEmpty) {
      return const Center(child: Text('Không có dữ liệu trạm đi qua'));
    }

    // Tạo danh sách timelineStops gồm điểm bắt đầu, các trạm, điểm kết thúc
    final List<Map<String, dynamic>> timelineStops = [
      {
        'name': startName,
        'latitude': startLatLng?.latitude,
        'longitude': startLatLng?.longitude,
        'distance': '',
        'isBusStop': false,
      },
      ...stops,
      {
        'name': endName,
        'latitude': endLatLng?.latitude,
        'longitude': endLatLng?.longitude,
        'distance': '',
        'isBusStop': false,
      },
    ];

    // Tính khoảng cách giữa các điểm liên tiếp
    final distance = Distance();
    for (int i = 1; i < timelineStops.length; i++) {
      final prevStop = timelineStops[i - 1];
      final currentStop = timelineStops[i];

      // Kiểm tra cả hai điểm đều có tọa độ
      if (prevStop['latitude'] != null &&
          prevStop['longitude'] != null &&
          currentStop['latitude'] != null &&
          currentStop['longitude'] != null) {
        final prevLatLng = LatLng(prevStop['latitude'], prevStop['longitude']);
        final currLatLng = LatLng(
          currentStop['latitude'],
          currentStop['longitude'],
        );

        // Tính khoảng cách bằng mét
        final distanceInMeters = distance.as(
          LengthUnit.Meter,
          prevLatLng,
          currLatLng,
        );

        // Định dạng khoảng cách
        String distanceStr;
        if (distanceInMeters < 1000) {
          distanceStr = '${distanceInMeters.round()} m';
        } else {
          distanceStr = '${(distanceInMeters / 1000).toStringAsFixed(1)} km';
        }

        // Lưu khoảng cách vào điểm hiện tại
        timelineStops[i]['distance'] = distanceStr;
      }
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      itemCount: timelineStops.length,
      itemBuilder: (context, index) {
        final stop = timelineStops[index];
        final stopName = stop['name'] ?? stop['stopName'] ?? '';
        final distance = stop['distance'] ?? '';
        final isBusStop = stop['isBusStop'] ?? true;
        final isFirst = index == 0;
        final isLast = index == timelineStops.length - 1;
        final isSelected = _selectedTimelineIndex == index;

        return _buildStopTimelineTile(
          stopName: stopName,
          distance: distance,
          isFirst: isFirst,
          isLast: isLast,
          isBusStop: isBusStop,
          isSelected: isSelected,
          onTap: () => _selectTimelineStop(index, timelineStops),
        );
      },
    );
  }

  // Widget hiển thị một bước trong chi tiết cách đi
  Widget _buildStepDetailCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String duration,
    required String distance,
    String? price,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey[600], size: 30),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                if (price != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      price,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                duration,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              Text(distance, style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ],
      ),
    );
  }

  // Widget hiển thị một mục trong timeline của các trạm dừng
  Widget _buildStopTimelineTile({
    required String stopName,
    required String distance,
    required bool isFirst,
    required bool isLast,
    required bool isBusStop,
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return IntrinsicHeight(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color:
                isSelected
                    ? Colors.green.withAlpha((0.1 * 255).toInt())
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Phần chỉ báo timeline (đường kẻ và hình tròn)
              SizedBox(
                width: 30,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        width: 2,
                        // Đường kẻ phía trên hình tròn
                        color: isFirst ? Colors.transparent : Colors.green,
                      ),
                    ),
                    Container(
                      width: isSelected ? 16 : 12,
                      height: isSelected ? 16 : 12,
                      decoration: BoxDecoration(
                        // Màu của hình tròn
                        color:
                            isBusStop
                                ? (isSelected
                                    ? Colors.green.shade700
                                    : Colors.green)
                                : (isSelected
                                    ? Colors.black87
                                    : Colors.black54),
                        shape: BoxShape.circle,
                        border:
                            isSelected
                                ? Border.all(color: Colors.white, width: 2)
                                : null,
                        boxShadow:
                            isSelected
                                ? [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(
                                      (0.3 * 255).toInt(),
                                    ),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                                : null,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        width: 2,
                        // Đường kẻ phía dưới hình tròn
                        color: isLast ? Colors.transparent : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Tên trạm
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      stopName,
                      style: TextStyle(
                        fontSize: isSelected ? 17 : 16,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        color:
                            isSelected ? Colors.green.shade800 : Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
              // Khoảng cách
              if (distance.isNotEmpty)
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    distance,
                    style: TextStyle(
                      color:
                          isSelected ? Colors.green.shade700 : Colors.blue[700],
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // --- New compact navigation card for bottom overlay ---
  Widget _buildCompactNavigationStepCard(BuildContext context) {
    final step = _navigationSteps[_currentStepIndex];
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(left: 12, right: 12, bottom: 16),
        child: Material(
          elevation: 8,
          borderRadius: const BorderRadius.all(Radius.circular(24)),
          color: Colors.white,
          child: GestureDetector(
            onHorizontalDragEnd: (details) {
              // Vuốt sang trái: sang bước tiếp theo
              if (details.primaryVelocity != null &&
                  details.primaryVelocity! < 0) {
                if (_currentStepIndex < _navigationSteps.length - 1) {
                  _moveToStep(_currentStepIndex + 1);
                }
              }
              // Vuốt sang phải: quay lại bước trước
              if (details.primaryVelocity != null &&
                  details.primaryVelocity! > 0) {
                if (_currentStepIndex > 0) {
                  _moveToStep(_currentStepIndex - 1);
                }
              }
            },
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (child, animation) {
                // Slide from right for next, left for previous
                final isForward = animation.status == AnimationStatus.forward;
                final offsetAnimation = Tween<Offset>(
                  begin: Offset(isForward ? 1.0 : -1.0, 0),
                  end: Offset.zero,
                ).animate(animation);
                return SlideTransition(
                  position: offsetAnimation,
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: Container(
                key: ValueKey(_currentStepIndex),
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 20,
                ),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                  color: Colors.white,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(step['icon'], color: Colors.grey[600], size: 30),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step['title'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            step['subtitle'],
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          if (step['price'] != null) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                step['price'],
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          step['duration'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        Text(
                          step['distance'] ?? '',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

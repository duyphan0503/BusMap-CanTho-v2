import 'package:busmapcantho/core/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// Dữ liệu giả để hiển thị, được lấy từ ảnh chụp màn hình
const LatLng _startLocation = LatLng(10.0290, 105.7720);
const LatLng _endLocation = LatLng(10.0255, 105.7895);
const LatLng _startBusStop = LatLng(10.0285, 105.7770);
const LatLng _endBusStop = LatLng(10.0258, 105.7890);

// Màn hình hiển thị chỉ đường, được thiết kế lại theo ảnh.
// Lớp này giữ nguyên để không làm ảnh hưởng đến điều hướng của ứng dụng.
// Tuy nhiên, nội dung bên trong sẽ hiển thị giao diện mới với dữ liệu cứng.
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

    return DirectionsDisplay(
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
class DirectionsDisplay extends StatefulWidget {
  final dynamic busRoute;
  final List<dynamic>? stopsPassingBy;
  final String? startName;
  final String? endName;
  final LatLng? startLatLng;
  final LatLng? endLatLng;

  const DirectionsDisplay({
    super.key,
    this.busRoute,
    this.stopsPassingBy,
    this.startName,
    this.endName,
    this.startLatLng,
    this.endLatLng,
  });

  @override
  State<DirectionsDisplay> createState() => _DirectionsDisplayState();
}

class _DirectionsDisplayState extends State<DirectionsDisplay>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green, // Màu nền chính
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Phần bản đồ ở nền
            _buildMap(),
            Column(
              children: [
                // Thanh thông tin điểm đi/đến ở trên
                _buildTopHeader(),
                // Nút "Bắt đầu dẫn đường"
                _buildStartNavigationButton(),
              ],
            ),
            // Bảng thông tin chi tiết có thể kéo
            _buildDraggableSheet(),
          ],
        ),
      ),
    );
  }

  // Widget hiển thị bản đồ
  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(initialCenter: _startLocation, initialZoom: 15.0),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        ),
        // Lớp vẽ đường đi
        PolylineLayer(
          polylines: [
            // Đường đi bộ đến trạm xe buýt
            Polyline(
              points: [_startLocation, _startBusStop],
              color: Colors.blue,
              strokeWidth: 5,
            ),
            // Đường đi của xe buýt
            Polyline(
              points: [_startBusStop, _endBusStop],
              color: Colors.green,
              strokeWidth: 5,
            ),
            // Đường đi bộ từ trạm xe buýt đến đích
            Polyline(
              points: [_endBusStop, _endLocation],
              color: Colors.blue,
              strokeWidth: 5,
            ),
          ],
        ),
        // Lớp đánh dấu các điểm trên bản đồ
        MarkerLayer(
          markers: [
            // Điểm bắt đầu
            Marker(
              width: 80.0,
              height: 80.0,
              point: _startLocation,
              child: const Icon(
                Icons.location_pin,
                color: Colors.red,
                size: 40,
              ),
            ),
            // Điểm kết thúc
            Marker(
              width: 80.0,
              height: 80.0,
              point: _endLocation,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.withAlpha(76), // 0.3 * 255 ≈ 76
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Center(
                  child: Icon(Icons.location_on, color: Colors.green, size: 30),
                ),
              ),
            ),
            // Các trạm dừng xe buýt
            Marker(
              point: _startBusStop,
              width: 20,
              height: 20,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.green, width: 3),
                ),
              ),
            ),
            Marker(
              point: _endBusStop,
              width: 20,
              height: 20,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.green, width: 3),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Widget cho thanh thông tin trên cùng
  Widget _buildTopHeader() {
    final startName = StringUtils.getShortName(widget.startName);
    final endName = StringUtils.getShortName(widget.endName);
    final routeNumber = widget.busRoute?.routeNumber ?? '...';

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(
                'Đi từ [ $startName ]',
                overflow: TextOverflow.ellipsis,
              ),
              dense: true,
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.location_on, color: Colors.green),
              title: Text('Đến [ $endName ]', overflow: TextOverflow.ellipsis),
              dense: true,
            ),
          ],
        ),
      ),
    );
  }

  // Widget cho nút "Bắt đầu dẫn đường"
  Widget _buildStartNavigationButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.navigation_outlined, color: Colors.white),
        label: const Text(
          'Bắt đầu dẫn đường',
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
    );
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
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10),
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
      _buildStepDetailCard(
        icon: Icons.directions_walk,
        title: 'Đi đến trạm $firstStop',
        subtitle: 'Xuất phát từ [ $startName ]',
        duration: walkingTime,
        distance: walkingDistance,
      ),
      _buildStepDetailCard(
        icon: Icons.directions_bus,
        title: 'Đi tuyến $routeNumber: $routeName',
        subtitle: '$firstStop → $lastStop',
        duration: busTime,
        distance: busDistance,
        price: fare,
      ),
      _buildStepDetailCard(
        icon: Icons.directions_walk,
        title: 'Xuống tại trạm $lastStop và đi tới điểm đến',
        subtitle: 'Đi đến [ $endName ]',
        duration: endWalkingTime,
        distance: endWalkingDistance,
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

        return _buildStopTimelineTile(
          stopName: stopName,
          distance: distance,
          isFirst: isFirst,
          isLast: isLast,
          isBusStop: isBusStop,
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
  }) {
    return IntrinsicHeight(
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
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    // Màu của hình tròn
                    color: isBusStop ? Colors.green : Colors.black,
                    shape: BoxShape.circle,
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
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
                  color: Colors.blue[700],
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

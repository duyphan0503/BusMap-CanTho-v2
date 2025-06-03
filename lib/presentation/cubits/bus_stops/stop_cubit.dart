import 'package:busmapcantho/domain/usecases/bus_stops/get_all_bus_stops_usecase.dart';
import 'package:busmapcantho/domain/usecases/bus_stops/get_nearby_bus_stops_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart' as osm;
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart' as osm;

import '../../../data/model/bus_stop.dart';

part 'stop_state.dart';

@injectable
class StopCubit extends Cubit<StopState> {
  final GetNearbyBusStopsUseCase _getNearbyBusStops;
  final GetAllBusStopsUseCase _getAllBusStops;

  final List<BusStop> _allLoadedStops = []; // Lưu tất cả các trạm đã tải
  List<BusStop> _visibleStops = []; // Lưu các trạm hiển thị hiện tại
  int _currentOffset = 0; // Vị trí bắt đầu từ server
  bool _hasMore = true; // Có dữ liệu để tải thêm không
  bool _isLoadingMore = false;
  DateTime? _lastUpdated;
  osm.LatLng? _lastUserPosition;
  double _lastRadius = 3000; // Lưu bán kính để sử dụng khi load more
  // Số lượng trạm mỗi lần tải

  StopCubit(this._getNearbyBusStops, this._getAllBusStops) : super(StopInitial());

  Future<void> fetchAllStops() async {
    emit(StopLoading());

    try {
      final stops = await _getAllBusStops();
      _allLoadedStops.addAll(stops);
      _visibleStops = List.from(_allLoadedStops); // Hiển thị tất cả trạm ban đầu
      _currentOffset = stops.length;
      _hasMore = false; // Không còn dữ liệu để tải thêm
      _lastUpdated = DateTime.now();

      emit(
        StopLoaded(
          stops: List.of(_visibleStops),
          hasMore: _hasMore,
          isLoadingMore: false,
          lastUpdated: _lastUpdated,
        ),
      );
    } catch (e) {
      emit(StopError(e.toString()));
    }
  }

  // Future<void> fetchStopsByBounds(osm.LatLngBounds? bounds) async {
  //   if (bounds == null) return;
  //
  //   emit(StopLoading());
  //
  //   try {
  //     final center = osm.LatLng(
  //       (bounds.north + bounds.south) / 2,
  //       (bounds.east + bounds.west) / 2,
  //     );
  //     final radius = _calculateDiagonalDistance(bounds) / 2;
  //
  //     final newStops = await _getNearbyBusStops(
  //       center.latitude,
  //       center.longitude,
  //       radiusInMeters: radius,
  //       limit: 100,
  //       offset: 0,
  //     );
  //
  //     // Lọc các trạm mới (chưa có trong _allLoadedStops) dựa trên id
  //     final existingStopIds = _allLoadedStops.map((stop) => stop.id).toSet();
  //     final uniqueNewStops =
  //         newStops.where((stop) => !existingStopIds.contains(stop.id)).toList();
  //
  //     // Thêm các trạm mới vào _allLoadedStops
  //     _allLoadedStops.addAll(uniqueNewStops);
  //
  //     // Cập nhật _visibleStops: Chỉ giữ các trạm nằm trong bounds
  //     _visibleStops = List.from(_allLoadedStops);
  //     _visibleStops.retainWhere(
  //       (stop) => bounds.contains(osm.LatLng(stop.latitude, stop.longitude)),
  //     );
  //
  //     // Cập nhật offset và trạng thái
  //     _currentOffset = newStops.length;
  //     _hasMore = newStops.length == 100;
  //     _lastUpdated = DateTime.now();
  //
  //     emit(
  //       StopLoaded(
  //         stops: List.of(_visibleStops),
  //         hasMore: _hasMore,
  //         isLoadingMore: false,
  //         lastUpdated: _lastUpdated,
  //       ),
  //     );
  //   } catch (e) {
  //     emit(StopError(e.toString()));
  //   }
  // }


  double _calculateDiagonalDistance(osm.LatLngBounds bounds) {
    const osm.Distance distance = osm.Distance();
    final northEast = osm.LatLng(bounds.north, bounds.east);
    final southWest = osm.LatLng(bounds.south, bounds.west);
    return distance(northEast, southWest);
  }

  Future<void> loadNearbyBusStops(
    double lat,
    double lng, {
    double radiusInMeters = 3000,
    required int initialCount,
  }) async {
    emit(StopLoading());
    _currentOffset = 0;
    _hasMore = true;
    _isLoadingMore = false;
    _lastUserPosition = osm.LatLng(lat, lng);
    _lastRadius = radiusInMeters;

    try {
      final stops = await _getNearbyBusStops(
        lat,
        lng,
        radiusInMeters: radiusInMeters,
        limit: initialCount,
        offset: _currentOffset,
      );

      // Sắp xếp các trạm theo khoảng cách
      const osm.Distance distance = osm.Distance();
      stops.sort((a, b) {
        final distA = distance(
          _lastUserPosition!,
          osm.LatLng(a.latitude, a.longitude),
        );
        final distB = distance(
          _lastUserPosition!,
          osm.LatLng(b.latitude, b.longitude),
        );
        return distA.compareTo(distB);
      });

      // Thêm vào _allLoadedStops và cập nhật _visibleStops
      final existingStopIds = _allLoadedStops.map((stop) => stop.id).toSet();
      final uniqueNewStops =
          stops.where((stop) => !existingStopIds.contains(stop.id)).toList();
      _allLoadedStops.addAll(uniqueNewStops);

      // Cập nhật _visibleStops từ _allLoadedStops, giữ nguyên thứ tự theo khoảng cách
      _visibleStops = List.from(_allLoadedStops);
      _visibleStops.sort((a, b) {
        final distA = distance(
          _lastUserPosition!,
          osm.LatLng(a.latitude, a.longitude),
        );
        final distB = distance(
          _lastUserPosition!,
          osm.LatLng(b.latitude, b.longitude),
        );
        return distA.compareTo(distB);
      });

      // Cập nhật trạng thái
      _currentOffset += stops.length;
      _hasMore = stops.length == initialCount;

      emit(
        StopLoaded(
          stops: List.of(_visibleStops),
          hasMore: _hasMore,
          isLoadingMore: false,
          lastUpdated: DateTime.now(),
        ),
      );
    } catch (e) {
      emit(StopError(e.toString()));
    }
  }

  Future<void> loadMoreNearbyBusStops({required int count}) async {
    if (!_hasMore || _isLoadingMore) return;

    _isLoadingMore = true;
    emit(
      StopLoaded(
        stops: List.of(_visibleStops),
        hasMore: _hasMore,
        isLoadingMore: true,
        lastUpdated: _lastUpdated,
      ),
    );

    try {
      final newStops = await _getNearbyBusStops(
        _lastUserPosition!.latitude,
        _lastUserPosition!.longitude,
        radiusInMeters: _lastRadius,
        limit: count,
        offset: _currentOffset,
      );

      const osm.Distance distance = osm.Distance();
      newStops.sort((a, b) {
        final distA = distance(
          _lastUserPosition!,
          osm.LatLng(a.latitude, a.longitude),
        );
        final distB = distance(
          _lastUserPosition!,
          osm.LatLng(b.latitude, b.longitude),
        );
        return distA.compareTo(distB);
      });

      // Lọc các trạm mới và thêm vào _allLoadedStops
      final existingStopIds = _allLoadedStops.map((stop) => stop.id).toSet();
      final uniqueNewStops =
          newStops.where((stop) => !existingStopIds.contains(stop.id)).toList();
      _allLoadedStops.addAll(uniqueNewStops);

      // Cập nhật _visibleStops từ _allLoadedStops, giữ nguyên thứ tự theo khoảng cách
      _visibleStops = List.from(_allLoadedStops);
      _visibleStops.sort((a, b) {
        final distA = distance(
          _lastUserPosition!,
          osm.LatLng(a.latitude, a.longitude),
        );
        final distB = distance(
          _lastUserPosition!,
          osm.LatLng(b.latitude, b.longitude),
        );
        return distA.compareTo(distB);
      });

      _currentOffset += newStops.length;
      _hasMore = newStops.length == count;

      _isLoadingMore = false;
      emit(
        StopLoaded(
          stops: List.of(_visibleStops),
          hasMore: _hasMore,
          isLoadingMore: false,
          lastUpdated: _lastUpdated,
        ),
      );
    } catch (e) {
      _isLoadingMore = false;
      emit(StopError(e.toString()));
    }
  }
}

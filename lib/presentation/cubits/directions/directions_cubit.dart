import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/services/osrm_service.dart';

part 'directions_state.dart';

@injectable
class DirectionsCubit extends Cubit<DirectionsState> {
  final OsrmService _osrmService;

  // Lưu trữ kết quả theo phương tiện
  final Map<String, DirectionsLoaded> _cachedResults = {};

  // Lưu trữ tọa độ điểm đầu và cuối
  LatLng? _lastStart;
  LatLng? _lastEnd;

  DirectionsCubit(this._osrmService) : super(DirectionsInitial());

  Map<String, DirectionsLoaded> getCachedResults() {
    return _cachedResults;
  }

  Future<void> getDirectionsForAllModes(
      LatLng start,
      LatLng end,
      ) async {
    _lastStart = start;
    _lastEnd = end;

    emit(DirectionsLoading());

    const modes = ['car', 'walk', 'motorbike'];
    bool hasError = false;
    String errorMessage = '';

    for (var mode in modes) {
      try {
        final result = await _osrmService.getDirections(start, end, mode: mode);
        if (result == null) {
          hasError = true;
          errorMessage = 'Không thể tìm thấy đường đi với $mode.';
          continue;
        }

        final directionState = DirectionsLoaded(
          polylinePoints: result.polyline,
          distanceText: result.distanceText,
          durationText: result.durationText,
          steps: result.steps,
          transportInfo: result.transportInfo,
          transportMode: mode,
          hasElevation: result.hasElevation,
          ascend: result.ascend,
          descend: result.descend,
        );

        _cachedResults[mode] = directionState;

        // Emit trạng thái cho phương tiện đầu tiên (car) để hiển thị ngay
        if (mode == 'car') {
          emit(directionState);
        }
      } catch (e) {
        debugPrint('Directions error for $mode: $e');
        hasError = true;
        errorMessage = 'Lỗi khi tìm đường với $mode: ${e.toString()}';
      }
    }

    if (hasError && _cachedResults.isEmpty) {
      emit(DirectionsError(errorMessage));
    } else if (hasError) {
      // Nếu có lỗi nhưng đã tải được ít nhất một phương tiện, vẫn emit trạng thái hiện tại
      emit(_cachedResults['car'] ?? DirectionsError(errorMessage));
    }
  }

  Future<void> getDirections(
      LatLng start,
      LatLng end,
      {String mode = 'car'}
      ) async {
    _lastStart = start;
    _lastEnd = end;

    if (_cachedResults.containsKey(mode)) {
      emit(_cachedResults[mode]!);
      return;
    }

    emit(DirectionsLoading());

    try {
      final result = await _osrmService.getDirections(
          start,
          end,
          mode: mode
      );

      if (result == null) {
        emit(DirectionsError('Không thể tìm thấy đường đi với phương tiện này.'));
        return;
      }

      final directionState = DirectionsLoaded(
        polylinePoints: result.polyline,
        distanceText: result.distanceText,
        durationText: result.durationText,
        steps: result.steps,
        transportInfo: result.transportInfo,
        transportMode: mode,
        hasElevation: result.hasElevation,
        ascend: result.ascend,
        descend: result.descend,
      );

      _cachedResults[mode] = directionState;
      emit(directionState);
    } catch (e) {
      debugPrint('Directions error: $e');
      emit(DirectionsError('Lỗi khi tìm đường: ${e.toString()}'));
    }
  }

  Future<void> changeTransportMode(
      String mode,
      LatLng start,
      LatLng end
      ) async {
    final currentState = state;
    if (currentState is DirectionsLoaded) {
      if (currentState.transportMode == mode) {
        return;
      }
    }

    if (_cachedResults.containsKey(mode)) {
      emit(_cachedResults[mode]!);
      return;
    }

    await getDirections(start, end, mode: mode);
  }

  void clearDirections() {
    _cachedResults.clear();
    _lastStart = null;
    _lastEnd = null;
    emit(DirectionsInitial());
  }
}

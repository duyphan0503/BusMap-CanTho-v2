import 'package:busmapcantho/data/repositories/bus_stop_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../data/model/bus_stop.dart';

part 'stop_state.dart';

@injectable
class StopCubit extends Cubit<StopState> {
  final BusStopRepository _repository;

  StopCubit(this._repository) : super(StopInitial());

  Future<List<BusStop>> loadNearbyBusStops(
    double lat,
    double lng, {
    double radiusInMeters = 1000,
  }) async {
    emit(StopLoading());
    try {
      final stops = await _repository.getNearbyBusStops(
        lat,
        lng,
        radiusInMeters,
      );
      emit(StopLoaded(stops));
      return stops;
    } catch (e) {
      emit(StopError(e.toString()));
      return [];
    }
  }
}

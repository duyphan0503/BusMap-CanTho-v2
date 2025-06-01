import 'package:injectable/injectable.dart';

import '../../../data/model/bus_stop.dart';
import '../../../data/repositories/bus_stop_repository.dart';

@injectable
class GetNearbyBusStopsUseCase {
  final BusStopRepository _repository;

  GetNearbyBusStopsUseCase(this._repository);

  Future<List<BusStop>> call(
      double lat,
      double lng, {
        double radiusInMeters = 3000,
        int limit = 10,
        int offset = 0,
      }) async {
    return await _repository.getNearbyBusStops(
      lat,
      lng,
      radiusInMeters,
      limit: limit,
      offset: offset,
    );
  }
}
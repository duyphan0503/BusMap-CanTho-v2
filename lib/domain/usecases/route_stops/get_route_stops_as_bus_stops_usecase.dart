import 'package:injectable/injectable.dart';

import '../../../data/model/bus_stop.dart';
import '../../../data/repositories/route_stops_repository.dart';

@injectable
class GetRouteStopsAsBusStopsUseCase {
  final RouteStopsRepository _repository;

  GetRouteStopsAsBusStopsUseCase(this._repository);

  /// Get all bus stops for a specific route and direction, ordered by sequence
  Future<List<BusStop>> call(String routeId, int direction) => 
      _repository.getRouteStopsAsBusStops(routeId, direction);
}

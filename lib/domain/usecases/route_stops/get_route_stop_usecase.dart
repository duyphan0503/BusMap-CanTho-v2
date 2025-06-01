import 'package:injectable/injectable.dart';

import '../../../data/model/route_stop.dart';
import '../../../data/repositories/route_stops_repository.dart';

@injectable
class GetRouteStopUseCase {
  final RouteStopsRepository _repository;

  GetRouteStopUseCase(this._repository);

  /// Get a specific route stop by route, stop, and direction
  Future<RouteStop?> call(String routeId, String stopId, int direction) => 
      _repository.getRouteStop(routeId, stopId, direction);
}

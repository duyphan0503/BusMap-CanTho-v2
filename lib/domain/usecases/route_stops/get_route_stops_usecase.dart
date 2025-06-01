import 'package:injectable/injectable.dart';

import '../../../data/model/route_stop.dart';
import '../../../data/repositories/route_stops_repository.dart';

@injectable
class GetRouteStopsUseCase {
  final RouteStopsRepository _repository;

  GetRouteStopsUseCase(this._repository);

  /// Get all route stops for a specific route and direction
  Future<List<RouteStop>> call(String routeId, int direction) => 
      _repository.getRouteStops(routeId, direction);
}

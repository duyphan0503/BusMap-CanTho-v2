import 'package:busmapcantho/data/repositories/route_stops_repository.dart';
import 'package:injectable/injectable.dart';

import '../../../data/model/route_stop.dart';

@injectable
class GetRouteStopsForRouteUseCase {
  final RouteStopsRepository repository;

  GetRouteStopsForRouteUseCase(this.repository);

  Future<List<RouteStop>> call(String routeId) {
    return repository.getRouteStopsForRoute(routeId);
  }
}

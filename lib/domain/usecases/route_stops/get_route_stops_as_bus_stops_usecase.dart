import 'package:injectable/injectable.dart';
import '../../../data/model/bus_stop.dart';
import '../../../data/repositories/route_stops_repository.dart';

@injectable
class GetRouteStopsAsBusStopsUseCase {
  final RouteStopsRepository repository;
  GetRouteStopsAsBusStopsUseCase(this.repository);
  Future<List<BusStop>> call(String routeId, int direction) =>
      repository.getRouteStopsAsBusStops(routeId, direction);
}


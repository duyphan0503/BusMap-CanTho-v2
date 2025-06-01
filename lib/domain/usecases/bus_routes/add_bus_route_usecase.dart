import '../../../data/model/bus_route.dart';
import '../../../data/repositories/bus_route_repository.dart';

class AddBusRouteUseCase {
  final BusRouteRepository _repo;

  AddBusRouteUseCase(this._repo);

  Future<void> call(BusRoute route) => _repo.addBusRoute(route);
}

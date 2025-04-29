import '../../../data/model/bus_route.dart';
import '../../../data/repositories/bus_route_repository.dart';

class GetBusRouteByIdUseCase {
  final BusRouteRepository _repo;

  GetBusRouteByIdUseCase(this._repo);

  Future<BusRoute?> call(String id) => _repo.getBusRouteById(id);
}

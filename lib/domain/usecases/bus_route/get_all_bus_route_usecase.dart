import 'package:busmapcantho/data/repositories/bus_route_repository.dart';

import '../../../data/model/bus_route.dart';

class GetAllBusRouteUseCase {
  final BusRouteRepository _repo;

  GetAllBusRouteUseCase(this._repo);

  Future<List<BusRoute>> call() async {
    return await _repo.getAllBusRoutes();
  }
}

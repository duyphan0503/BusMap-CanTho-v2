import 'package:busmapcantho/data/repositories/bus_route_repository.dart';
import 'package:injectable/injectable.dart';

import '../../../data/model/bus_route.dart';

@injectable
class GetAllBusRoutesUseCase {
  final BusRouteRepository _repo;

  GetAllBusRoutesUseCase(this._repo);

  Future<List<BusRoute>> call() async {
    return await _repo.getAllBusRoutes();
  }
}

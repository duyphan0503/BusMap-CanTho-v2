import '../../../data/model/bus_stop.dart';
import '../../../data/repositories/bus_stop_repository.dart';

class GetAllBusStopsUseCase {
  final BusStopRepository _repo;
  GetAllBusStopsUseCase(this._repo);

  Future<List<BusStop>> call() => _repo.getAllBusStops();
}
import 'package:injectable/injectable.dart';

import '../../../data/model/bus_stop.dart';
import '../../../data/repositories/bus_stop_repository.dart';

@injectable
class GetBusStopByIdUseCase {
  final BusStopRepository _repo;
  GetBusStopByIdUseCase(this._repo);

  Future<BusStop?> call(String id) => _repo.getBusStopById(id);
}
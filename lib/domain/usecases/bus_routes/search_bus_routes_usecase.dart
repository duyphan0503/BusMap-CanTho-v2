import 'package:injectable/injectable.dart';
import '../../../data/model/bus_route.dart';
import '../../../data/repositories/bus_route_repository.dart';

@injectable
class SearchBusRoutesUseCase {
  final BusRouteRepository repository;
  SearchBusRoutesUseCase(this.repository);
  Future<List<BusRoute>> call(String query) => repository.searchBusRoutes(query);
}


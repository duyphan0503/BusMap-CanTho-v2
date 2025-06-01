import 'package:injectable/injectable.dart';

import '../../../data/repositories/route_stops_repository.dart';

@injectable
class GetRoutesForStopUseCase {
  final RouteStopsRepository _repository;

  GetRoutesForStopUseCase(this._repository);

  /// Get all route IDs that pass through a specific stop
  Future<List<String>> call(String stopId) => 
      _repository.getRoutesForStop(stopId);
}

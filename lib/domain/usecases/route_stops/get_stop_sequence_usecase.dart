import 'package:injectable/injectable.dart';

import '../../../data/repositories/route_stops_repository.dart';

@injectable
class GetStopSequenceUseCase {
  final RouteStopsRepository _repository;

  GetStopSequenceUseCase(this._repository);

  /// Get the sequence number of a stop within a route
  Future<int?> call(String routeId, String stopId, int direction) => 
      _repository.getStopSequence(routeId, stopId, direction);
}

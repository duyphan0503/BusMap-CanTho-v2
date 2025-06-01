import 'package:injectable/injectable.dart';

import '../../../data/repositories/route_stops_repository.dart';

@injectable
class IsStopOnRouteUseCase {
  final RouteStopsRepository _repository;

  IsStopOnRouteUseCase(this._repository);

  /// Check if a stop is part of a specific route and direction
  Future<bool> call(String routeId, String stopId, int direction) => 
      _repository.isStopOnRoute(routeId, stopId, direction);
}

import 'package:injectable/injectable.dart';

import '../../../data/repositories/favorite_route_repository.dart';

@injectable
class RemoveFavoriteRouteUseCase {
  final FavoriteRouteRepository repo;

  RemoveFavoriteRouteUseCase(this.repo);

  Future<void> call(String routeId) =>
      repo.removeFavoriteRoute(routeId);
}

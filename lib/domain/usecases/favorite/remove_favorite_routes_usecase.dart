import '../../../data/repositories/favorite_route_repository.dart';

class RemoveFavoriteRouteUseCase {
  final FavoriteRouteRepository repo;

  RemoveFavoriteRouteUseCase(this.repo);

  Future<void> call(String userId, String routeId) =>
      repo.removeFavoriteRoute(userId, routeId);
}

import '../../../data/repositories/favorite_route_repository.dart';

class SaveFavoriteRouteUseCase {
  final FavoriteRouteRepository _repo;

  SaveFavoriteRouteUseCase(this._repo);

  Future<void> call(String userId, String routeId) =>
      _repo.saveFavoriteRoute(userId, routeId);
}

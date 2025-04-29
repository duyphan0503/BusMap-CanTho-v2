import 'package:busmapcantho/data/repositories/favorite_route_repository.dart';

class GetFavoriteRoutesUseCase {
  final FavoriteRouteRepository _repo;

  GetFavoriteRoutesUseCase(this._repo);

  Future<List<String>> call(String userId) => _repo.getFavoriteRoutes(userId);
}

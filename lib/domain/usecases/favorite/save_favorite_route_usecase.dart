import 'package:injectable/injectable.dart';

import '../../../data/repositories/favorite_route_repository.dart';

@injectable
class SaveFavoriteRouteUseCase {
  final FavoriteRouteRepository _repo;

  SaveFavoriteRouteUseCase(this._repo);

  Future<void> call(String routeId) => _repo.saveFavoriteRoute(routeId);
}

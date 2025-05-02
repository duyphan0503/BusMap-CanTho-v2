import 'package:busmapcantho/data/repositories/favorite_route_repository.dart';
import 'package:busmapcantho/domain/usecases/auth/get_current_user_usecase.dart';
import 'package:injectable/injectable.dart';

import '../../../data/model/bus_route.dart';

@injectable
class GetFavoriteRoutesUseCase {
  final FavoriteRouteRepository _repo;
  final GetCurrentUserUseCase _getUser;

  GetFavoriteRoutesUseCase(this._repo, this._getUser);

  Future<List<BusRoute>> call() async {
    final user = await _getUser();
    if (user == null) {
      return [];
    }
    return await _repo.getFavoriteRoutes();
  }
}

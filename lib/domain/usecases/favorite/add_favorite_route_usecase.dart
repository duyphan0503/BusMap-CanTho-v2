import 'package:injectable/injectable.dart';

import '../../../data/model/user_favorite.dart';
import '../../../data/repositories/user_favorite_repository.dart';

@injectable
class AddFavoriteRouteUseCase {
  final UserFavoriteRepository repository;

  AddFavoriteRouteUseCase(this.repository);

  Future<UserFavorite?> call({required String routeId, String? label}) =>
      repository.addFavoriteRoute(routeId: routeId, label: label);
}

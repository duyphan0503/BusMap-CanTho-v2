import 'package:injectable/injectable.dart';

import '../../../data/repositories/user_favorite_repository.dart';

@injectable
class RemoveFavoriteUseCase {
  final UserFavoriteRepository _repository;

  RemoveFavoriteUseCase(this._repository);

  Future<void> call(String favoriteId) async {
    await _repository.removeFavorite(favoriteId);
  }
}

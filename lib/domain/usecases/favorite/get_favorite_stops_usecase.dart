import 'package:injectable/injectable.dart';

import '../../../data/model/user_favorite.dart';
import '../../../data/repositories/user_favorite_repository.dart';

@injectable
class GetFavoriteStopsUseCase {
  final UserFavoriteRepository repository;

  GetFavoriteStopsUseCase(this.repository);

  Future<List<UserFavorite>> call() => repository.getFavoriteStops();
}

import 'package:injectable/injectable.dart';
import '../../../data/model/user_favorite.dart';
import '../../../data/repositories/user_favorite_repository.dart';

@injectable
class GetFavoriteRoutesUseCase {
  final UserFavoriteRepository repository;
  GetFavoriteRoutesUseCase(this.repository);
  Future<List<UserFavorite>> call() => repository.getFavoriteRoutes();
}


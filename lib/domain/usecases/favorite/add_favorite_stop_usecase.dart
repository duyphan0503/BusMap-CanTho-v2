import 'package:injectable/injectable.dart';

import '../../../data/model/user_favorite.dart';
import '../../../data/repositories/user_favorite_repository.dart';

@injectable
class AddFavoriteStopUseCase {
  final UserFavoriteRepository repository;

  AddFavoriteStopUseCase(this.repository);

  Future<UserFavorite> call({required String stopId, String? label}) =>
      repository.addFavoriteStop(stopId: stopId, label: label);
}
import 'package:busmapcantho/domain/entities/account_user_entity.dart';
import 'package:injectable/injectable.dart';

import '../../repositories/auth_repository.dart';

@injectable
class UpdateDisplayNameUseCase {
  final AuthRepository _repo;

  UpdateDisplayNameUseCase(this._repo);

  Future<AccountUserEntity> call(String fullName) =>
      _repo.updateDisplayName(fullName);
}

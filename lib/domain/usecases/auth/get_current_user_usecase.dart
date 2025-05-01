import 'package:busmapcantho/domain/entities/account_user_entity.dart';
import 'package:injectable/injectable.dart';

import '../../repositories/auth_repository.dart';

@injectable
class GetCurrentUserUseCase {
  final AuthRepository _repo;

  GetCurrentUserUseCase(this._repo);

  Future<AccountUserEntity?> call() => _repo.getCurrentUser();
}

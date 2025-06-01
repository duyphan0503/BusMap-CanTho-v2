import 'package:injectable/injectable.dart';

import '../../repositories/auth_repository.dart';

@injectable
class ChangePasswordUseCase {
  final AuthRepository _repo;

  ChangePasswordUseCase(this._repo);

  Future<void> call({required String oldPassword, required String newPassword}) =>
      _repo.changePassword(oldPassword, newPassword);
}

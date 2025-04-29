import '../../repositories/auth_repository.dart';

class ChangePasswordUseCase {
  final AuthRepository _repo;

  ChangePasswordUseCase(this._repo);

  Future<void> call(String newPassword) => _repo.changePassword(newPassword);
}

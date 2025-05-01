import 'package:injectable/injectable.dart';

import '../../repositories/auth_repository.dart';

@injectable
class SignOutUseCase {
  final AuthRepository _repo;

  SignOutUseCase(this._repo);

  Future<void> call() => _repo.signOut();
}

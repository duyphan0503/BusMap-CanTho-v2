import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../repositories/auth_repository.dart';

@injectable
class GetCurrentUserUseCase {
  final AuthRepository _repo;

  GetCurrentUserUseCase(this._repo);

  Future<User?> call() => _repo.getCurrentUser();
}

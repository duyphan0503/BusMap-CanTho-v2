import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../repositories/auth_repository.dart';

@injectable
class UpdateDisplayNameUseCase {
  final AuthRepository _repo;

  UpdateDisplayNameUseCase(this._repo);

  Future<User> call(String fullName) => _repo.updateDisplayName(fullName);
}

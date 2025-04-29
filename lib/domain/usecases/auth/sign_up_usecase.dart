import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository _repo;

  SignUpUseCase(this._repo);

  Future<AuthResponse> call(String email, String password) =>
      _repo.signUpWithEmail(email, password);
}

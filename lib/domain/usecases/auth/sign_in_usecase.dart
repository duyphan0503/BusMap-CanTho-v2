import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository _repo;

  SignInUseCase(this._repo);

  Future<AuthResponse> call(String email, String password) =>
      _repo.signInWithEmail(email, password);
}

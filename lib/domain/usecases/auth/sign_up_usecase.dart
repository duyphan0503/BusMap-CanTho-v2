import 'package:busmapcantho/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@injectable
class SignUpUseCase {
  final AuthRepository _repo;

  SignUpUseCase(this._repo);

  Future<AuthResponse> call(String email, String password, String fullName) =>
      _repo.signUpWithEmail(email, password, fullName);
}

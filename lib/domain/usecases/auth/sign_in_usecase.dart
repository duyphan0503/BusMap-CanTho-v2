import 'package:busmapcantho/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@injectable
class SignInUseCase {
  final AuthRepository _repo;

  SignInUseCase(this._repo);

  Future<AuthResponse> call(String email, String password) =>
      _repo.signInWithEmail(email, password);
}

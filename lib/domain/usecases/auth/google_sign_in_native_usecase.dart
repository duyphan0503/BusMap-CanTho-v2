import 'package:busmapcantho/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@injectable
class GoogleSignInNativeUseCase {
  final AuthRepository _repo;

  GoogleSignInNativeUseCase(this._repo);

  Future<AuthResponse> call() => _repo.signInWithGoogleNative();
}

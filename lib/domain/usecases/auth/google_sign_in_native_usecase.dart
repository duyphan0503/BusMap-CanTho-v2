import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/repositories/auth_repository.dart';

class GoogleSignInNativeUseCase {
  final AuthRepository _repo;

  GoogleSignInNativeUseCase(this._repo);

  Future<AuthResponse> call() => _repo.signInWithGoogleNative();
}

import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../repositories/auth_repository.dart';

@injectable
class UpdateProfileImageUseCase {
  final AuthRepository _repo;

  UpdateProfileImageUseCase(this._repo);

  Future<User> call(File file) => _repo.updateProfileImage(file);
}

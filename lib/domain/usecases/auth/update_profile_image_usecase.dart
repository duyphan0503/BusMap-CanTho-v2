import 'dart:io';

import 'package:busmapcantho/domain/entities/account_user_entity.dart';
import 'package:injectable/injectable.dart';

import '../../repositories/auth_repository.dart';

@injectable
class UpdateProfileImageUseCase {
  final AuthRepository _repo;

  UpdateProfileImageUseCase(this._repo);

  Future<AccountUserEntity> call(File file) => _repo.updateProfileImage(file);
}
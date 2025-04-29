import 'dart:io';

import 'package:busmapcantho/domain/entities/account_user_entity.dart';

abstract class AuthRepository {
  Future<AccountUserEntity?> getCurrentUser();
  Future<AccountUserEntity> updateDisplayName(String fullName);
  Future<AccountUserEntity> updateProfileImage(File file);
  Future<void> changePassword(String newPassword);
  Future<void> signOut();
}
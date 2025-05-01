import 'dart:io';

import 'package:busmapcantho/domain/entities/account_user_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {

  Future<AuthResponse> signInWithEmail(String email, String password);

  Future<AuthResponse> signUpWithEmail(
      String email,
      String password,
      String fullName,
      );

  Future<AuthResponse> signInWithGoogleNative();

  Future<AccountUserEntity?> getCurrentUser();

  Future<AccountUserEntity> updateDisplayName(String fullName);

  Future<AccountUserEntity> updateProfileImage(File file);

  Future<void> changePassword(String newPassword);

  Future<void> signOut();

  Future<void> requestPasswordResetOtp({required String email});

  Future<void> verifyEmailOtp({required String email, required String otp});

  Future<void> resetPasswordWithOtp({
    required String email,
    required String otp,
    required String newPassword,
  });
}

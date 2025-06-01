import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  Future<void> initAuthListener();

  Future<AuthResponse> signInWithEmail(String email, String password);

  Future<AuthResponse> signUpWithEmail(
    String email,
    String password,
    String fullName,
  );

  Future<AuthResponse> signInWithGoogleNative();

  Future<User?> getCurrentUser();

  Future<User> updateDisplayName(String fullName);

  Future<User> updateProfileImage(File file);

  Future<void> changePassword(String oldPassword, String newPassword);

  Future<void> signOut();

  Future<void> requestPasswordResetOtp({required String email});

  Future<void> verifyEmailOtp({required String email, required String otp});

  Future<void> resetPasswordWithOtp({
    required String email,
    required String otp,
    required String newPassword,
  });

  Future<String?> getStoredToken();
}

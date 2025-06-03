import 'dart:io';

import 'package:busmapcantho/data/datasources/auth_remote_datasource.dart';
import 'package:busmapcantho/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remote;

  AuthRepositoryImpl(this._remote);

  @override
  Future<void> initAuthListener() async {
    _remote.initAuthListener();
    return Future.value();
  }

  @override
  Future<AuthResponse> signInWithEmail(String email, String password) =>
      _remote.signInWithEmail(email, password);

  @override
  Future<AuthResponse> signUpWithEmail(
    String email,
    String password,
    String fullName,
  ) => _remote.signUpWithEmail(email, password, fullName);

  @override
  Future<AuthResponse> signInWithGoogleNative() =>
      _remote.signInWithGoogleNative();

  @override
  Future<void> verifyEmailOtp({required String email, required String otp}) =>
      _remote.verifyEmailOtp(email: email, otp: otp);

  @override
  Future<void> requestPasswordResetOtp({required String email}) =>
      _remote.requestPasswordResetOtp(email: email);

  @override
  Future<void> resetPasswordWithOtp({
    required String email,
    required String otp,
    required String newPassword,
  }) => _remote.resetPasswordWithOtp(
    email: email,
    otp: otp,
    newPassword: newPassword,
  );

  @override
  Future<Map<String, dynamic>?> getUserProfile() => _remote.getUserProfile();

  @override
  Future<User> updateDisplayName(String fullName) =>
      _remote.updateDisplayName(fullName);

  @override
  Future<User> updateProfileImage(File file) =>
      _remote.updateProfileImage(file);

  @override
  Future<void> changePassword(String oldPassword, String newPassword) =>
      _remote.changePassword(oldPassword, newPassword);

  @override
  Future<User?> getCurrentUser() => _remote.getCurrentUser();

  @override
  Future<void> signOut() => _remote.signOut();

  @override
  Future<String?> getStoredToken() => _remote.getAccessToken();
}

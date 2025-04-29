import 'dart:io';

import 'package:busmapcantho/data/datasources/auth_remote_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/account_user_entity.dart';
import '../../domain/repositories/auth_repository.dart' as domain;

class AuthRepository implements domain.AuthRepository {
  final AuthRemoteDatasource _authRemoteDatasource;

  AuthRepository([AuthRemoteDatasource? authRemoteDatasource])
    : _authRemoteDatasource = authRemoteDatasource ?? AuthRemoteDatasource();

  Future<AuthResponse> signInWithEmail(String email, String password) =>
      _authRemoteDatasource.signInWithEmail(email, password);

  Future<AuthResponse> signUpWithEmail(String email, String password) =>
      _authRemoteDatasource.signUpWithEmail(email, password);

  Future<AuthResponse> signInWithGoogleNative() =>
      _authRemoteDatasource.signInWithGoogleNative();

  Future<void> verifyEmailOtp({required String email, required String otp}) =>
      _authRemoteDatasource.verifyEmailOtp(email: email, otp: otp);

  Future<void> requestPasswordResetOtp({required String email}) =>
      _authRemoteDatasource.requestPasswordResetOtp(email: email);

  Future<void> resetPasswordWithOtp({
    required String email,
    required String otp,
    required String newPassword,
  }) => _authRemoteDatasource.resetPasswordWithOtp(
    email: email,
    otp: otp,
    newPassword: newPassword,
  );

  @override
  Future<AccountUserEntity> updateDisplayName(String fullName) =>
      _authRemoteDatasource.updateDisplayName(fullName);

  @override
  Future<AccountUserEntity> updateProfileImage(File file) =>
      _authRemoteDatasource.updateProfileImage(file);

  @override
  Future<void> changePassword(String newPassword) =>
      _authRemoteDatasource.changePassword(newPassword);

  @override
  Future<AccountUserEntity?> getCurrentUser() =>
      _authRemoteDatasource.getCurrentUser();

  @override
  Future<void> signOut() => _authRemoteDatasource.signOut();

  /*Future<void> changePassword({
    required String email,
    required String oldPassword,
    required String newPassword,
  }) => _authRemoteDatasource.changePassword(
    email: email,
    oldPassword: oldPassword,
    newPassword: newPassword,
  );*/
}

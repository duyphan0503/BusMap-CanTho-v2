import 'dart:io';

import 'package:busmapcantho/data/datasources/auth_remote_datasource.dart';
import 'package:busmapcantho/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/account_user_entity.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _authRemoteDatasource;

  AuthRepositoryImpl([AuthRemoteDatasource? authRemoteDatasource])
    : _authRemoteDatasource = authRemoteDatasource ?? AuthRemoteDatasource();

  @override
  Future<AuthResponse> signInWithEmail(String email, String password) =>
      _authRemoteDatasource.signInWithEmail(email, password);

  @override
  Future<AuthResponse> signUpWithEmail(
    String email,
    String password,
    String fullName,
  ) => _authRemoteDatasource.signUpWithEmail(email, password, fullName);

  @override
  Future<AuthResponse> signInWithGoogleNative() =>
      _authRemoteDatasource.signInWithGoogleNative();

  @override
  Future<void> verifyEmailOtp({required String email, required String otp}) =>
      _authRemoteDatasource.verifyEmailOtp(email: email, otp: otp);

  @override
  Future<void> requestPasswordResetOtp({required String email}) =>
      _authRemoteDatasource.requestPasswordResetOtp(email: email);

  @override
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

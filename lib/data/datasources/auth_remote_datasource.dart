import 'dart:io';

import 'package:busmapcantho/configs/env.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@lazySingleton
class AuthRemoteDatasource {
  final SupabaseClient _client;

  AuthRemoteDatasource([SupabaseClient? client])
    : _client = client ?? Supabase.instance.client;

  // No longer needed as we're using the built-in auth.users table
  // void initAuthListener() { ... }

  Future<AuthResponse> signInWithEmail(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) {
        throw Exception('Failed to sign in - no user returned');
      }
      return response;
    } on AuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<AuthResponse> signUpWithEmail(
    String email,
    String password,
    String fullName,
  ) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );
      if (response.user == null) {
        throw Exception('Failed to sign up - no user returned');
      }

      return response;
    } on AuthException catch (e) {
      if (e.message.toLowerCase().contains('already registered')) {
        throw Exception(
          'This email is already registered. Please use a different email or try logging in.',
        );
      }
      throw Exception(e.message);
    }
  }

  Future<AuthResponse> signInWithGoogleNative() async {
    final googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile'],
      clientId: iosClientId,
      serverClientId: webClientId,
    );
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) throw Exception('Google sign-in was cancelled');
    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;
    final accessToken = googleAuth.accessToken;
    if (idToken == null || accessToken == null) {
      throw Exception('Failed to get Google authentication tokens');
    }
    final response = await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
    if (response.user == null) {
      throw Exception('Failed to sign in with Google - no user returned');
    }
    return response;
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<User?> getCurrentUser() async {
    return _client.auth.currentUser;
  }

  Future<User> updateDisplayName(String fullName) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('No user is currently signed in');

    final response = await _client.auth.updateUser(
      UserAttributes(data: {'full_name': fullName, ...user.userMetadata ?? {}}),
    );

    final updatedUser = response.user;
    if (updatedUser == null) {
      throw Exception('Failed to update profile image - no user returned');
    }
    return updatedUser;
  }

  Future<User> updateProfileImage(File file) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('No user is currently signed in');

    final bytes = await file.readAsBytes();
    final ext = file.path.split('.').last;
    final storagePath = 'avatars/${user.id}.$ext';

    await _client.storage
        .from('avatars')
        .updateBinary(
          storagePath,
          bytes,
          fileOptions: FileOptions(upsert: true),
        );

    final url = _client.storage.from('avatars').getPublicUrl(storagePath);

    final response = await _client.auth.updateUser(
      UserAttributes(data: {'avatar_url': url, ...user.userMetadata ?? {}}),
    );

    final updatedUser = response.user;
    if (updatedUser == null) {
      throw Exception('Failed to update profile image - no user returned');
    }
    return updatedUser;
  }

  Future<void> changePassword(String newPassword) async {
    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  Future<void> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    final response = await _client.auth.verifyOTP(
      type: OtpType.email,
      email: email,
      token: otp,
    );
    if (response.user == null && response.session == null) {
      throw Exception('Failed to verify OTP - no user or session returned');
    }
  }

  Future<void> requestPasswordResetOtp({required String email}) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      if (e.code == 'user_not_found') {
        throw Exception(
          'This email is not registered. Please use a different email.',
        );
      }
      throw Exception(e.message);
    }
  }

  Future<void> resetPasswordWithOtp({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await _client.auth.verifyOTP(
        email: email,
        token: otp,
        type: OtpType.recovery,
      );
      if (response.user == null) {
        throw Exception('Failed to verify OTP - no user returned');
      }

      await _client.auth.updateUser(UserAttributes(password: newPassword));
    } on AuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<String?> getAccessToken() async {
    final session = _client.auth.currentSession;
    if (session == null) {
      return null;
    }
    if (session.isExpired) {
      final res = await _client.auth.refreshSession();
      return res.session?.accessToken;
    }
    return session.accessToken;
  }
}

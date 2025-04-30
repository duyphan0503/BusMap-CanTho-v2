import 'dart:io';

import 'package:busmapcantho/configs/env.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/user.dart';

class AuthRemoteDatasource {
  final SupabaseClient _client;

  AuthRemoteDatasource([SupabaseClient? client])
    : _client = client ?? Supabase.instance.client;

  void initAuthListener() {
    _client.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      final user = data.session?.user;
      if (event == AuthChangeEvent.signedIn && user != null) {
        await _client.from('users').upsert({
          'id': user.id,
          'email': user.email,
          'full_name': user.userMetadata?['full_name'],
          'avatar_url': user.userMetadata?['avatar_url'],
          'role': 'user',
          'last_sign_in_at': DateTime.now().toIso8601String(),
        }, onConflict: 'id');
      }
    });
  }

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

  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
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

  Future<AccountUser?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    final userData =
        await _client.from('users').select().eq('id', user.id).maybeSingle();
    if (userData == null) return null;
    return AccountUser.fromJson(userData);
  }

  Future<AccountUser> updateDisplayName(String fullName) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('No user is currently signed in');
    await _client
        .from('users')
        .update({'full_name': fullName})
        .eq('id', user.id);
    return (await getCurrentUser())!;
  }

  Future<AccountUser> updateProfileImage(File file) async {
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
    await _client.from('users').update({'avatar_url': url}).eq('id', user.id);
    return (await getCurrentUser())!;
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

  /*Future<void> changePassword({
    required String email,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: oldPassword,
      );
      if (response.user == null) {
        throw Exception('Old password is incorrect');
      }

      await _client.auth.updateUser(UserAttributes(password: newPassword));
    } on AuthException catch (e) {
      if (e.code == 'invalid_credentials') {
        throw Exception('Old password is incorrect');
      }
      throw Exception(e.message);
    }
  }*/
}

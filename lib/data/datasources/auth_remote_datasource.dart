import 'dart:async';
import 'dart:io';

import 'package:busmapcantho/configs/env.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/di/injection.dart';

@lazySingleton
class AuthRemoteDatasource {
  final SupabaseClient _client;

  AuthRemoteDatasource(this._client);

  final logger = getIt<Logger>();

  void initAuthListener() {
    late final StreamSubscription<AuthState> sub;
    sub = _client.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      final user = data.session?.user;
      if (user != null && (event == AuthChangeEvent.signedIn)) {
        final fullName = user.userMetadata?['full_name'] as String? ?? '';
        final avatarUrl = user.userMetadata?['avatar_url'] as String? ?? '';
        await _client.from('users').upsert({
          'id': user.id,
          'email': user.email,
          'full_name': fullName,
          'avatar_url': avatarUrl,
        }, onConflict: 'id');
        sub.cancel();
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
        throw Exception(tr('errorSignInNoUser'));
      }
      return response;
    } on AuthException catch (e, stack) {
      logger.e('signInWithEmail error', error: e, stackTrace: stack);
      throw Exception(tr('errorSignIn', args: [e.message]));
    } catch (e, stack) {
      logger.e('signInWithEmail error', error: e, stackTrace: stack);
      throw Exception(tr('errorSignInGeneric'));
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
        throw Exception(tr('errorSignUpNoUser'));
      }
      return response;
    } on AuthException catch (e, stack) {
      logger.e('signUpWithEmail error', error: e, stackTrace: stack);
      if (e.message.toLowerCase().contains('already registered')) {
        throw Exception(tr('errorEmailRegistered'));
      }
      throw Exception(tr('errorSignUp', args: [e.message]));
    } catch (e, stack) {
      logger.e('signUpWithEmail error', error: e, stackTrace: stack);
      throw Exception(tr('errorSignUpGeneric'));
    }
  }

  Future<AuthResponse> signInWithGoogleNative() async {
    final googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile'],
      clientId: iosClientId,
      serverClientId: webClientId,
    );
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) throw Exception(tr('errorGoogleSignInCancelled'));
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;
      if (idToken == null || accessToken == null) {
        throw Exception(tr('errorGoogleToken'));
      }
      final response = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
      if (response.user == null) {
        throw Exception(tr('errorGoogleSignInNoUser'));
      }
      return response;
    } on PlatformException catch (e, stack) {
      logger.e(
        'signInWithGoogleNative PlatformException',
        error: e,
        stackTrace: stack,
      );
      throw Exception(tr('errorGoogleSignInPlatform'));
    } on AuthException catch (e, stack) {
      logger.e(
        'signInWithGoogleNative AuthException',
        error: e,
        stackTrace: stack,
      );
      throw Exception(tr('errorGoogleSignIn', args: [e.message]));
    } catch (e, stack) {
      logger.e('signInWithGoogleNative error', error: e, stackTrace: stack);
      throw Exception(tr('errorGoogleSignInGeneric'));
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e, stack) {
      logger.e('signOut error', error: e, stackTrace: stack);
      throw Exception(tr('errorSignOut'));
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      return _client.auth.currentUser;
    } catch (e, stack) {
      logger.e('getCurrentUser error', error: e, stackTrace: stack);
      throw Exception(tr('errorGetCurrentUser'));
    }
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception(tr('errorNoUserSignedIn'));
      final response =
          await _client.from('users').select('*').eq('id', user.id).single();
      return response as Map<String, dynamic>?;
    } catch (e, stack) {
      logger.e('getUserProfile error', error: e, stackTrace: stack);
      throw Exception(tr('errorGetUserProfile'));
    }
  }

  Future<User> updateDisplayName(String fullName) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception(tr('errorNoUserSignedIn'));
      await _client.from('users').upsert({
        'id': user.id,
        'full_name': fullName,
      }, onConflict: 'id');
      return user;
    } catch (e, stack) {
      logger.e('updateDisplayName error', error: e, stackTrace: stack);
      throw Exception(tr('errorUpdateDisplayName'));
    }
  }

  Future<User> updateProfileImage(File file) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception(tr('errorNoUserSignedIn'));
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

      final url = await _client.storage
          .from('avatars')
          .createSignedUrl(storagePath, 60 * 60);

      final response = await _client.auth.updateUser(
        UserAttributes(data: {'avatar_url': url, ...user.userMetadata ?? {}}),
      );

      final updatedUser = response.user;
      if (updatedUser == null) {
        throw Exception(tr('errorUpdateProfileImageNoUser'));
      }
      return updatedUser;
    } catch (e, stack) {
      logger.e('updateProfileImage error', error: e, stackTrace: stack);
      throw Exception(tr('errorUpdateProfileImage'));
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception(tr('errorNoUserSignedIn'));
      final email = user.email;
      if (email == null) throw Exception(tr('errorNoEmailForUser'));
      try {
        final signInRes = await _client.auth.signInWithPassword(
          email: email,
          password: oldPassword,
        );
        if (signInRes.user == null) {
          throw Exception(tr('errorOldPasswordIncorrect'));
        }
      } on AuthException {
        throw Exception(tr('errorOldPasswordIncorrect'));
      }
      await _client.auth.updateUser(UserAttributes(password: newPassword));
    } catch (e, stack) {
      logger.e('changePassword error', error: e, stackTrace: stack);
      throw Exception(tr('errorChangePassword'));
    }
  }

  Future<void> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _client.auth.verifyOTP(
        type: OtpType.email,
        email: email,
        token: otp,
      );
      if (response.user == null && response.session == null) {
        throw Exception(tr('errorVerifyOtpNoUser'));
      }
    } catch (e, stack) {
      logger.e('verifyEmailOtp error', error: e, stackTrace: stack);
      throw Exception(tr('errorVerifyOtp'));
    }
  }

  Future<void> requestPasswordResetOtp({required String email}) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } on AuthException catch (e, stack) {
      logger.e(
        'requestPasswordResetOtp AuthException',
        error: e,
        stackTrace: stack,
      );
      if (e.code == 'user_not_found') {
        throw Exception(tr('errorEmailNotRegistered'));
      }
      throw Exception(tr('errorRequestResetOtp', args: [e.message]));
    } catch (e, stack) {
      logger.e('requestPasswordResetOtp error', error: e, stackTrace: stack);
      throw Exception(tr('errorRequestResetOtpGeneric'));
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
        throw Exception(tr('errorVerifyOtpNoUser'));
      }
      await _client.auth.updateUser(UserAttributes(password: newPassword));
    } on AuthException catch (e, stack) {
      logger.e(
        'resetPasswordWithOtp AuthException',
        error: e,
        stackTrace: stack,
      );
      throw Exception(tr('errorResetPassword', args: [e.message]));
    } catch (e, stack) {
      logger.e('resetPasswordWithOtp error', error: e, stackTrace: stack);
      throw Exception(tr('errorResetPasswordGeneric'));
    }
  }

  Future<String?> getAccessToken() async {
    try {
      final session = _client.auth.currentSession;
      if (session == null) {
        return null;
      }
      if (session.isExpired) {
        final res = await _client.auth.refreshSession();
        return res.session?.accessToken;
      }
      return session.accessToken;
    } catch (e, stack) {
      logger.e('getAccessToken error', error: e, stackTrace: stack);
      throw Exception(tr('errorGetAccessToken'));
    }
  }

  Future<void> resendEmailOtp({
    required String email,
    bool isReset = false,
  }) async {
    try {
      if (isReset) {
        await _client.auth.resetPasswordForEmail(email);
      } else {
        await _client.auth.resend(type: OtpType.email, email: email);
      }
    } on AuthException catch (e, stack) {
      logger.e('resendEmailOtp AuthException', error: e, stackTrace: stack);
      throw Exception(tr('errorResendOtp', args: [e.message]));
    } catch (e, stack) {
      logger.e('resendEmailOtp error', error: e, stackTrace: stack);
      throw Exception(tr('errorResendOtpGeneric'));
    }
  }
}

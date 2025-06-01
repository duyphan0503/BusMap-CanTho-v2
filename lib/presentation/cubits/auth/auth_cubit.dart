import 'dart:async';

import 'package:busmapcantho/domain/usecases/auth/get_current_user_usecase.dart';
import 'package:busmapcantho/domain/usecases/auth/google_sign_in_native_usecase.dart';
import 'package:busmapcantho/domain/usecases/auth/sign_in_usecase.dart';
import 'package:busmapcantho/domain/usecases/auth/sign_out_usecase.dart';
import 'package:busmapcantho/domain/usecases/auth/sign_up_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_state.dart';

@injectable
class AuthCubit extends Cubit<AuthState> {
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final SignUpUseCase _signUpUseCase;
  final SignInUseCase _signInUseCase;
  final GoogleSignInNativeUseCase _googleSignInNativeUseCase;
  final SignOutUseCase _signOutUseCase;
  StreamSubscription? _authStateSubscription;

  AuthCubit(
      this._getCurrentUserUseCase,
      this._signUpUseCase,
      this._signInUseCase,
      this._googleSignInNativeUseCase,
      this._signOutUseCase,
      ) : super(AuthInitial()) {
    _checkAuth();
    _authStateSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedOut) {
        if (state is! AuthUnauthenticated) emit(AuthUnauthenticated());
      } else if (event == AuthChangeEvent.signedIn ||
          event == AuthChangeEvent.tokenRefreshed ||
          event == AuthChangeEvent.userUpdated) {
        _checkAuth();
      }
    });
  }

  Future<void> _checkAuth() async {
    if (state is! AuthAuthenticated) {
      // Avoid emitting loading if already authenticated to prevent UI flicker on token refresh
      emit(AuthLoading());
    }
    try {
      final user = await _getCurrentUserUseCase();
      if (user != null) {
        // Only emit if the user is different or the state is not AuthAuthenticated
        if (state is! AuthAuthenticated || (state as AuthAuthenticated).user.id != user.id) {
          emit(AuthAuthenticated(user));
        }
      } else {
        if (state is! AuthUnauthenticated) {
          emit(AuthUnauthenticated());
        }
      }
    } catch (_) {
      if (state is! AuthUnauthenticated) {
        emit(AuthUnauthenticated());
      }
    }
  }

  Future<void> signUp(String email, String password, String fullName) async {
    emit(AuthLoading());
    try {
      await _signUpUseCase(email, password, fullName);
      emit(AuthVerifying());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signIn(String email, String password) async {
    emit(AuthLoading());
    try {
      await _signInUseCase(email, password);
      await _checkAuth(); // Re-check auth after sign-in attempt
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(AuthLoading());
    try {
      await _googleSignInNativeUseCase();
      await _checkAuth(); // Re-check auth after Google sign-in attempt
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signOut() async {
    emit(AuthLoading());
    try {
      await _signOutUseCase();
      // onAuthStateChange listener will handle emitting AuthUnauthenticated
    } catch (_) {
      // Even if sign out fails on the server, treat as unauthenticated locally.
      if (state is! AuthUnauthenticated) {
        emit(AuthUnauthenticated());
      }
    }
    // Ensure unauthenticated state is emitted if not already handled by listener quickly enough
    if (state is! AuthUnauthenticated) {
       emit(AuthUnauthenticated());
    }
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}

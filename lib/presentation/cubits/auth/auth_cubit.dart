import 'package:busmapcantho/domain/usecases/auth/get_current_user_usecase.dart';
import 'package:busmapcantho/domain/usecases/auth/google_sign_in_native_usecase.dart';
import 'package:busmapcantho/domain/usecases/auth/sign_in_usecase.dart';
import 'package:busmapcantho/domain/usecases/auth/sign_out_usecase.dart';
import 'package:busmapcantho/domain/usecases/auth/sign_up_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'auth_state.dart';

@injectable
class AuthCubit extends Cubit<AuthState> {
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final SignUpUseCase _signUpUseCase;
  final SignInUseCase _signInUseCase;
  final GoogleSignInNativeUseCase _googleSignInNativeUseCase;
  final SignOutUseCase _signOutUseCase;

  AuthCubit(
    this._getCurrentUserUseCase,
    this._signUpUseCase,
    this._signInUseCase,
    this._googleSignInNativeUseCase,
    this._signOutUseCase,
  ) : super(AuthInitial()) {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    emit(AuthLoading());
    try {
      final user = await _getCurrentUserUseCase();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (_) {
      emit(AuthUnauthenticated());
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
      await _checkAuth();
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(AuthLoading());
    try {
      await _googleSignInNativeUseCase();
      await _checkAuth();
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signOut() async {
    emit(AuthLoading());
    try {
      await _signOutUseCase();
    } catch (_) {}
    emit(AuthUnauthenticated());
  }
}

import 'package:busmapcantho/domain/usecases/auth/get_current_user_usecase.dart';
import 'package:busmapcantho/domain/usecases/auth/google_sign_in_native_usecase.dart';
import 'package:busmapcantho/domain/usecases/auth/sign_in_usecase.dart';
import 'package:busmapcantho/domain/usecases/auth/sign_out_usecase.dart';
import 'package:busmapcantho/domain/usecases/auth/sign_up_usecase.dart';
import 'package:busmapcantho/presentation/cubits/auth/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class AuthCubit extends Cubit<AuthState> {
  final SignUpUseCase _signUpUseCase;
  final SignInUseCase _signInUseCase;
  final GoogleSignInNativeUseCase _googleSignInNativeUseCase;

  AuthCubit(
    this._signUpUseCase,
    this._signInUseCase,
    this._googleSignInNativeUseCase,
  ) : super(AuthInitial());

  Future<void> signUp(String email, String password, String fullName) async {
    emit(AuthLoading());
    try {
      final response = await _signUpUseCase(email, password, fullName);
      if (response.user != null) {
        emit(AuthSuccess('Sign up successful. Please check your email for verification'));
      } else {
        emit(AuthError('Sign up failed'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signIn(String email, String password) async {
    emit(AuthLoading());
    try {
      final response = await _signInUseCase(email, password);
      if (response.user != null) {
        emit(AuthSuccess('Sign in successful'));
      } else {
        emit(AuthError('Sign in failed'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(AuthLoading());
    try {
      final response = await _googleSignInNativeUseCase();
      if (response.user != null) {
        emit(AuthSuccess('Google sign in successful'));
      } else {
        emit(AuthError('Google sign in failed'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}

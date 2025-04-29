import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/auth/request_password_reset_otp_usecase.dart';
import '../../../domain/usecases/auth/reset_password_with_otp_usecase.dart';

part 'password_state.dart';

class PasswordCubit extends Cubit<PasswordState> {
  final RequestPasswordResetOtpUseCase _requestPasswordResetOtpUseCase;
  final ResetPasswordWithOtpUseCase _resetPasswordWithOtpUseCase;

  PasswordCubit(
    this._requestPasswordResetOtpUseCase,
    this._resetPasswordWithOtpUseCase,
  ) : super(PasswordInitial());

  Future<void> requestPasswordResetOtp(String email) async {
    emit(PasswordLoading());
    try {
      await _requestPasswordResetOtpUseCase(email);
      emit(PasswordRequestOtpSuccess());
    } catch (e) {
      emit(PasswordError(e.toString()));
    }
  }

  Future<void> resetPasswordWithOtp({
    required String email,
    required String otpCode,
    required String newPassword,
  }) async {
    emit(PasswordLoading());
    try {
      await _resetPasswordWithOtpUseCase(
        email: email,
        otp: otpCode,
        newPassword: newPassword,
      );
      emit(PasswordResetSuccess());
    } catch (e) {
      emit(PasswordError(e.toString()));
    }
  }
}

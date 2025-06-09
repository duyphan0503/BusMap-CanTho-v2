import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/usecases/auth/request_password_reset_otp_usecase.dart';
import '../../../domain/usecases/auth/reset_password_with_otp_usecase.dart';

part 'password_state.dart';

@injectable
class PasswordCubit extends Cubit<PasswordState> {
  final RequestPasswordResetOtpUseCase _requestPasswordResetOtpUseCase;
  final ResetPasswordWithOtpUseCase _resetPasswordWithOtpUseCase;

  PasswordCubit(
    this._requestPasswordResetOtpUseCase,
    this._resetPasswordWithOtpUseCase,
  ) : super(PasswordEmailInputState());

  Future<void> requestPasswordResetOtp(String email) async {
    emit(PasswordLoading());
    try {
      await _requestPasswordResetOtpUseCase(email);
      emit(PasswordRequestOtpSuccess(email));
      emit(PasswordOtpInputState(email));
    } catch (e) {
      emit(PasswordError(e.toString()));
      emit(PasswordEmailInputState());
    }
  }

  void resendPasswordResetOtp(String email) async {
    emit(PasswordOtpResending(email));
    try {
      await _requestPasswordResetOtpUseCase(email);
      emit(PasswordOtpResent(email));
      emit(PasswordOtpInputState(email));
    } catch (e) {
      emit(PasswordOtpResendError(email, e.toString()));
      emit(PasswordOtpInputState(email));
    }
  }

  void proceedToNewPasswordStep(String email, String otpCode) {
    emit(PasswordNewPasswordInputState(email, otpCode));
  }

  void goBackToEmailInput() {
    emit(PasswordEmailInputState());
  }

  void goBackToOtpInput(String email) {
    emit(PasswordOtpInputState(email));
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
      emit(PasswordNewPasswordInputState(email, otpCode));
    }
  }
}

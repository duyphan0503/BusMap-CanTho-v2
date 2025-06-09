import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

// Assume ResendEmailOtpUseCase exists or will be created in a similar path
import '../../../domain/usecases/auth/resend_email_otp_usecase.dart';
import '../../../domain/usecases/auth/verify_email_otp_usecase.dart';
import 'otp_state.dart';

@injectable
class OtpCubit extends Cubit<OtpState> {
  final VerifyEmailOtpUseCase _verifyEmailOtpUseCase;
  final ResendEmailOtpUseCase _resendEmailOtpUseCase; // Added dependency

  OtpCubit(this._verifyEmailOtpUseCase, this._resendEmailOtpUseCase)
    : super(OtpInitial()); // Updated constructor

  Future<void> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    emit(OtpLoading());
    try {
      await _verifyEmailOtpUseCase(email: email, otp: otp);
      emit(OtpVerified());
    } catch (e) {
      emit(OtpError(e.toString()));
    }
  }

  Future<void> resendEmailOtp({required String email}) async {
    emit(OtpResending());
    try {
      await _resendEmailOtpUseCase(email: email);
      emit(OtpResent());
    } catch (e) {
      emit(OtpResendError(e.toString()));
    }
  }
}

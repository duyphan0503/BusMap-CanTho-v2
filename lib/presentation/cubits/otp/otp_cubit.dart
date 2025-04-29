import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/auth/verify_email_otp_usecase.dart';
import 'otp_state.dart';

class OtpCubit extends Cubit<OtpState> {
  final VerifyEmailOtpUseCase _verifyEmailOtpUseCase;

  OtpCubit(this._verifyEmailOtpUseCase) : super(OtpInitial());

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
}

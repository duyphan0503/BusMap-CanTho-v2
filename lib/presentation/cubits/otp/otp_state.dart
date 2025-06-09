abstract class OtpState {}

class OtpInitial extends OtpState {}

class OtpLoading extends OtpState {}

class OtpVerified extends OtpState {}

class OtpError extends OtpState {
  final String message;

  OtpError(this.message);
}

// New states for OTP resend
class OtpResending extends OtpState {}

class OtpResent extends OtpState {}

class OtpResendError extends OtpState {
  final String message;
  OtpResendError(this.message);
}

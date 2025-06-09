part of 'password_cubit.dart';

abstract class PasswordState {}

class PasswordInitial extends PasswordState {}

class PasswordEmailInputState extends PasswordState {}

class PasswordOtpInputState extends PasswordState {
  final String email;
  PasswordOtpInputState(this.email);
}

class PasswordNewPasswordInputState extends PasswordState {
  final String email;
  final String otpCode;
  PasswordNewPasswordInputState(this.email, this.otpCode);
}

class PasswordLoading extends PasswordState {}

class PasswordRequestOtpSuccess extends PasswordState {
  final String email;
  PasswordRequestOtpSuccess(this.email);
}

class PasswordResetSuccess extends PasswordState {}

class PasswordChangeSuccess extends PasswordState {}

class PasswordError extends PasswordState {
  final String message;
  PasswordError(this.message);
}

// New states for password OTP resend
class PasswordOtpResending extends PasswordState {
  final String email; // Keep email to potentially show in UI or for retry
  PasswordOtpResending(this.email);
}

class PasswordOtpResent extends PasswordState {
  final String email;
  PasswordOtpResent(this.email);
}

class PasswordOtpResendError extends PasswordState {
  final String email;
  final String message;
  PasswordOtpResendError(this.email, this.message);
}

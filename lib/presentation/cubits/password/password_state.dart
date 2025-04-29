part of 'password_cubit.dart';

abstract class PasswordState {}

class PasswordInitial extends PasswordState {}

class PasswordLoading extends PasswordState {}

class PasswordRequestOtpSuccess extends PasswordState {}

class PasswordResetSuccess extends PasswordState {}

class PasswordChangeSuccess extends PasswordState {}

class PasswordError extends PasswordState {
  final String message;
  PasswordError(this.message);
}
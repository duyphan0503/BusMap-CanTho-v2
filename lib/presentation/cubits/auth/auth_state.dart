part of 'auth_cubit.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;

  AuthAuthenticated(this.user);
}

class AuthUnauthenticated extends AuthState {}

class AuthVerifying extends AuthState {}

class AuthError extends AuthState {
  final String error;

  AuthError(this.error);
}


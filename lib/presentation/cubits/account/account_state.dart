part of 'account_cubit.dart';

abstract class AccountState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AccountInitial extends AccountState {}

class AccountLoading extends AccountState {}

class AccountLoaded extends AccountState {
  final AccountUserEntity user;

  AccountLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

class AccountUpdateSuccess extends AccountState {
  final String message;
  final AccountUserEntity user;

  AccountUpdateSuccess(this.message, this.user);

  @override
  List<Object?> get props => [message, user];
}

class AccountError extends AccountState {
  final String message;

  AccountError(this.message);

  @override
  List<Object?> get props => [message];
}

class AccountSignedOut extends AccountState {}

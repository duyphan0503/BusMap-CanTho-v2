part of 'account_cubit.dart';

abstract class AccountState extends Equatable {
  const AccountState();

  @override
  List<Object?> get props => [];
}

class AccountInitial extends AccountState {}

class AccountLoading extends AccountState {}

class AccountLoaded extends AccountState {
  final User user;

  const AccountLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

class AccountUpdateSuccess extends AccountState {
  final String message;
  final User user;

  const AccountUpdateSuccess(this.message, this.user);

  @override
  List<Object?> get props => [message, user];
}

class AccountError extends AccountState {
  final String message;

  const AccountError(this.message);

  @override
  List<Object?> get props => [message];
}

class AccountSignedOut extends AccountState {}

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
  final Map<String, dynamic>? userProfile;

  const AccountLoaded(this.user, [this.userProfile]);

  @override
  List<Object?> get props => [user, userProfile];
}

class AccountUpdateSuccess extends AccountState {
  final String message;
  final User user;
  final Map<String, dynamic>? userProfile;

  const AccountUpdateSuccess(this.message, this.user, [this.userProfile]);

  @override
  List<Object?> get props => [message, user, userProfile];
}

class AccountError extends AccountState {
  final String message;

  const AccountError(this.message);

  @override
  List<Object?> get props => [message];
}

class AccountSignedOut extends AccountState {}

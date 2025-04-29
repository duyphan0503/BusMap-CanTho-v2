import 'package:equatable/equatable.dart';

class AccountUserEntity extends Equatable {
  final String id;
  final String? email;
  final String? fullName;
  final String? avatarUrl;
  final String? role;

  const AccountUserEntity({
    required this.id,
    this.email,
    this.fullName,
    this.avatarUrl,
    this.role,
  });

  @override
  List<Object?> get props => [id, email, fullName, avatarUrl, role];
}
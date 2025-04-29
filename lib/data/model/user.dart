import 'package:busmapcantho/domain/entities/account_user_entity.dart';

class AccountUser extends AccountUserEntity {
  const AccountUser({
    required super.id,
    super.email,
    super.fullName,
    super.avatarUrl,
    super.role,
  });

  factory AccountUser.fromJson(Map<String, dynamic> json) => AccountUser(
    id: json['id'] as String,
    email: json['email'] as String?,
    fullName: json['full_name'] as String?,
    avatarUrl: json['avatar_url'] as String?,
    role: json['role'] as String?,
  );

  /*  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'full_name': fullName,
    'created_at': createdAt.toIso8601String(),
    'role': role,
    'last_login': lastLogin?.toIso8601String(),
  };*/
}

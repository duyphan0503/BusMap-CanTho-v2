import 'package:equatable/equatable.dart';

class AppNotification extends Equatable {
  final String id;
  final String userId;
  final String message;
  final DateTime sentAt;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.message,
    required this.sentAt,
  });

  @override
  List<Object?> get props => [id, userId, message, sentAt];

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'].toString(),
      userId: json['user_id'],
      message: json['message'],
      sentAt: DateTime.parse(json['sent_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'message': message,
      'sent_at': sentAt.toIso8601String(),
    };
  }

  AppNotification copyWith({
    String? id,
    String? userId,
    String? message,
    DateTime? sentAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      message: message ?? this.message,
      sentAt: sentAt ?? this.sentAt,
    );
  }
}

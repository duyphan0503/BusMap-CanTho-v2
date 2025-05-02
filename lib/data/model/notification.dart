class AppNotification {
  final String id;
  final String userId;
  final String message;
  final DateTime sentAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.message,
    required this.sentAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        message: json['message'] as String,
        sentAt: DateTime.parse(json['sent_at'] as String),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'message': message,
    'sent_at': sentAt.toIso8601String(),
  };
}

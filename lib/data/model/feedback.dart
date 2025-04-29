class Feedback {
  final String id;
  final String userId;
  final String content;
  final DateTime createdAt;

  Feedback({
    required this.id,
    required this.userId,
    required this.content,
    required this.createdAt,
  });

  factory Feedback.fromJson(Map<String, dynamic> json) => Feedback(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    content: json['content'] as String,
    createdAt: DateTime.parse(json['created_at']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'content': content,
    'created_at': createdAt.toIso8601String(),
  };
}

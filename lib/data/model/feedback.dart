class FeedbackModel {
  final String id;
  final String userId;
  final String content;
  final DateTime createdAt;

  FeedbackModel({
    required this.id,
    required this.userId,
    required this.content,
    required this.createdAt,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) =>
      FeedbackModel(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        content: json['content'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'content': content,
    'created_at': createdAt.toIso8601String(),
  };
}

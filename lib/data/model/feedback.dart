import 'package:equatable/equatable.dart';

class FeedbackModel extends Equatable {
  final String id;
  final String userId;
  final String? userName;
  final String routeId;
  final int rating;
  final String? content;
  final DateTime createdAt;

  const FeedbackModel({
    required this.id,
    required this.userId,
    this.userName,
    required this.routeId,
    required this.rating,
    this.content,
    required this.createdAt,
  });

  factory FeedbackModel.fromMap(Map<String, dynamic> m) => FeedbackModel(
    id: m['id'] as String,
    userId: m['user_id'] as String,
    userName: m['user_name'] as String?,
    routeId: m['route_id'] as String,
    rating: m['rating'] as int,
    content: m['content'] as String?,
    createdAt: DateTime.parse(m['created_at'] as String),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'user_id': userId,
    'user_name': userName,
    'route_id': routeId,
    'rating': rating,
    'content': content,
    'created_at': createdAt.toIso8601String(),
  };

  @override
  List<Object?> get props => [id, userId, userName, routeId, rating, content, createdAt];
}

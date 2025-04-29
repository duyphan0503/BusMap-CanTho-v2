class SearchHistory {
  final String id;
  final String userId;
  final String keyword;
  final DateTime searchedAt;

  SearchHistory({
    required this.id,
    required this.userId,
    required this.keyword,
    required this.searchedAt,
  });

  factory SearchHistory.fromJson(Map<String, dynamic> json) => SearchHistory(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    keyword: json['keyword'] as String,
    searchedAt: DateTime.parse(json['searched_at']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'keyword': keyword,
    'searched_at': searchedAt.toIso8601String(),
  };
}
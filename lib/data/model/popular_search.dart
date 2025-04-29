class PopularSearch {
  final String id;
  final String keyword;
  final int count;

  PopularSearch({
    required this.id,
    required this.keyword,
    required this.count,
  });

  factory PopularSearch.fromJson(Map<String, dynamic> json) => PopularSearch(
    id: json['id'] as String,
    keyword: json['keyword'] as String,
    count: json['count'] as int,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'keyword': keyword,
    'count': count,
  };
}
class RouteImage {
  final String id;
  final String routeId;
  final String url;
  final DateTime uploadedAt;
  final String? thumbnailUrl;

  RouteImage({
    required this.id,
    required this.routeId,
    required this.url,
    required this.uploadedAt,
    this.thumbnailUrl,
  });

  factory RouteImage.fromJson(Map<String, dynamic> json) => RouteImage(
    id: json['id'] as String,
    routeId: json['route_id'] as String,
    url: json['url'] as String,
    uploadedAt: DateTime.parse(json['uploaded_at']),
    thumbnailUrl: json['thumbnail_url'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'route_id': routeId,
    'url': url,
    'uploaded_at': uploadedAt.toIso8601String(),
    'thumbnail_url': thumbnailUrl,
  };
}
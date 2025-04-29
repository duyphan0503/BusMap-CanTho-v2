class BusRoute {
  final String id;
  final String name;
  final String? code;
  final String? color;
  final DateTime createdAt;
  final String? description;
  final Map<String, dynamic>? schedule; // jsonb

  BusRoute({
    required this.id,
    required this.name,
    this.code,
    this.color,
    required this.createdAt,
    this.description,
    this.schedule,
  });

  factory BusRoute.fromJson(Map<String, dynamic> json) => BusRoute(
    id: json['id'] as String,
    name: json['name'] as String,
    code: json['code'] as String?,
    color: json['color'] as String?,
    createdAt: DateTime.parse(json['created_at']),
    description: json['description'] as String?,
    schedule: json['schedule'] is Map<String, dynamic>
        ? json['schedule'] as Map<String, dynamic>
        : json['schedule'] != null
        ? Map<String, dynamic>.from(json['schedule'])
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'code': code,
    'color': color,
    'created_at': createdAt.toIso8601String(),
    'description': description,
    'schedule': schedule,
  };
}
class Agency {
  final String id;
  final String name;
  final String? phone;
  final String? website;
  final DateTime createdAt;
  final DateTime updatedAt;

  Agency({
    required this.id,
    required this.name,
    this.phone,
    this.website,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Agency.fromJson(Map<String, dynamic> json) {
    return Agency(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      website: json['website'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'website': website,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}

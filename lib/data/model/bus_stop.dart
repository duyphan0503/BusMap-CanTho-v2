class BusStop {
  final String id;
  final String? stopCode;
  final String name;
  final double latitude;
  final double longitude;
  final String? address;
  final DateTime createdAt;
  final DateTime updatedAt;

  BusStop({
    required this.id,
    this.stopCode,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.address,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BusStop.fromJson(Map<String, dynamic> json) {
    return BusStop(
      id: json['id'] as String,
      stopCode: json['stop_code'] as String?,
      name: json['name'] as String? ?? 'Unknown',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      address: json['address'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'stop_code': stopCode,
    'name': name,
    'latitude': latitude,
    'longitude': longitude,
    'address': address,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}

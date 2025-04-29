class BusStop {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final String? address;
  final DateTime createdAt;
  final String? description;
  final String? imageUrl;

  BusStop({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    this.address,
    required this.createdAt,
    this.description,
    this.imageUrl,
  });

  factory BusStop.fromJson(Map<String, dynamic> json) => BusStop(
    id: json['id'] as String,
    name: json['name'] as String,
    lat: (json['lat'] as num).toDouble(),
    lng: (json['lng'] as num).toDouble(),
    address: json['address'] as String?,
    createdAt: DateTime.parse(json['created_at']),
    description: json['description'] as String?,
    imageUrl: json['image_url'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'lat': lat,
    'lng': lng,
    'address': address,
    'created_at': createdAt.toIso8601String(),
    'description': description,
    'image_url': imageUrl,
  };
}
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
    // Handle different location formats
    double lat, lng;
    
    if (json['location'] is Map<String, dynamic>) {
      // GeoJSON format: {"type": "Point", "coordinates": [longitude, latitude]}
      final loc = json['location'] as Map<String, dynamic>;
      if (loc.containsKey('coordinates') && loc['coordinates'] is List) {
        lng = (loc['coordinates'][0] as num).toDouble();
        lat = (loc['coordinates'][1] as num).toDouble();
      } else {
        throw FormatException('Invalid location format: ${loc.toString()}');
      }
    } else if (json.containsKey('latitude') && json.containsKey('longitude')) {
      // Simple lat/lng format
      lat = (json['latitude'] as num).toDouble();
      lng = (json['longitude'] as num).toDouble();
    } else {
      // Request Supabase to convert the geography type to lat/lng values
      // This requires a modification to how we query the stops table
      throw FormatException('Location data missing in bus stop: ${json.toString()}');
    }

    return BusStop(
      id: json['id'] as String,
      stopCode: json['stop_code'] as String?,
      name: json['name'] as String,
      latitude: lat,
      longitude: lng,
      address: json['address'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'stop_code': stopCode,
    'name': name,
    'location': {
      'type': 'Point',
      'coordinates': [longitude, latitude],
    },
    'address': address,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}

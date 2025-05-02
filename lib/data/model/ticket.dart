class Ticket {
  final String id;
  final String userId;
  final String? routeId;
  final String? fromStopId;
  final String? toStopId;
  final DateTime purchasedAt;
  final String status;
  final double? price;

  Ticket({
    required this.id,
    required this.userId,
    this.routeId,
    this.fromStopId,
    this.toStopId,
    required this.purchasedAt,
    required this.status,
    this.price,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) => Ticket(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    routeId: json['route_id'] as String?,
    fromStopId: json['from_stop_id'] as String?,
    toStopId: json['to_stop_id'] as String?,
    purchasedAt: DateTime.parse(json['purchased_at'] as String),
    status: json['status'] as String,
    price:
    json['price'] != null ? (json['price'] as num).toDouble() : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'route_id': routeId,
    'from_stop_id': fromStopId,
    'to_stop_id': toStopId,
    'purchased_at': purchasedAt.toIso8601String(),
    'status': status,
    'price': price,
  };
}

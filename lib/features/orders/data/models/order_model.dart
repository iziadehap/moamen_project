// order_model.dart

enum WeekDay { monday, tuesday, wednesday, thursday, friday, saturday, sunday }

enum OrderStatus { pending, accepted, inProgress, completed, cancelled }

enum OrderPriority { low, medium, high, urgent }

enum OrderType { pickup, delivery, pickupAndReturn }

class Order {
  final String id;
  final String title;
  final String description;
  final OrderStatus status;
  final OrderPriority priority;
  final OrderType orderType;
  final String? workerId; // nullable
  final String publicArea;
  final String? publicLandmark;
  final List<Map<String, dynamic>> availability; // JSONB → List of maps
  final String? fullAddress;
  final double? latitude;
  final double? longitude;
  final String? contactName;
  final String? contactPhone;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? acceptedAt;

  Order({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.orderType,
    this.workerId,
    required this.publicArea,
    this.publicLandmark,
    required this.availability,
    this.fullAddress,
    this.latitude,
    this.longitude,
    this.contactName,
    this.contactPhone,
    required this.createdAt,
    this.updatedAt,
    this.acceptedAt,
  });

  // ===================== fromJson =====================
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      status: _statusFromString(json['status'] as String),
      priority: _priorityFromString(json['priority'] as String),
      orderType: _typeFromString(json['order_type'] as String),
      workerId: json['worker_id'] as String?,
      publicArea: json['public_area'] as String,
      publicLandmark: json['public_landmark'] as String?,
      availability: (json['availability'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      fullAddress: json['full_address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      contactName: json['contact_name'] as String?,
      contactPhone: json['contact_phone'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      acceptedAt: json['accepted_at'] != null
          ? DateTime.parse(json['accepted_at'] as String)
          : null,
    );
  }

  // ===================== toJson (لو احتجتها) =====================
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status.name,
      'priority': priority.name,
      'order_type': orderType.name,
      'worker_id': workerId,
      'public_area': publicArea,
      'public_landmark': publicLandmark,
      'availability': availability,
      'full_address': fullAddress,
      'latitude': latitude,
      'longitude': longitude,
      'contact_name': contactName,
      'contact_phone': contactPhone,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'accepted_at': acceptedAt?.toIso8601String(),
    };
  }
}

// ===================== Helper Functions =====================
OrderStatus _statusFromString(String value) {
  return OrderStatus.values.firstWhere(
    (e) => e.name == value,
    orElse: () => OrderStatus.pending,
  );
}

OrderPriority _priorityFromString(String value) {
  return OrderPriority.values.firstWhere(
    (e) => e.name == value,
    orElse: () => OrderPriority.medium,
  );
}

OrderType _typeFromString(String value) {
  return OrderType.values.firstWhere(
    (e) => e.name == value,
    orElse: () => OrderType.pickup,
  );
}

// order_model.dart

enum WeekDay { monday, tuesday, wednesday, thursday, friday, saturday, sunday }

enum OrderStatus { pending, accepted, completed, cancelled }

enum OrderPriority { low, medium, high, urgent }

// enum OrderType { pickup, delivery, pickupAndReturn }

class Order {
  final String id;
  final String title;
  final String description;
  final OrderStatus status;
  final OrderPriority priority;
  // final OrderType orderType;
  final String? workerId; // nullable
  // final String? workerName;
  final String publicArea;
  // final String? publicLandmark;
  final List<Map<String, dynamic>> availability; // JSONB → List of maps
  final String? fullAddress;
  final double? latitude;
  final double? longitude;
  final String? contactName;
  final String? contactPhone;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? acceptedAt;

  final List<String> photoUrls;

  Order({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    // required this.orderType,
    this.workerId,
    // this.workerName,
    required this.publicArea,
    // this.publicLandmark,
    required this.availability,
    this.fullAddress,
    this.latitude,
    this.longitude,
    this.contactName,
    this.contactPhone,
    this.createdAt,
    this.updatedAt,
    this.acceptedAt,
    this.photoUrls = const [],
  });

  // ===================== fromJson =====================
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      status: _statusFromString(json['status'] as String),
      priority: _priorityFromString(json['priority'] as String),
      // orderType: _typeFromString(json['order_type'] as String),
      workerId: json['worker_id'] as String?,
      // workerName: json['worker_name'] as String?,
      publicArea: json['public_area'] as String,
      //   publicLandmark: json['public_landmark'] as String?,
      availability:
          (json['availability'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>?)
              .whereType<Map<String, dynamic>>()
              .toList() ??
          [],
      fullAddress: json['full_address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      contactName: json['contact_name'] as String?,
      contactPhone: json['contact_phone'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      acceptedAt: json['accepted_at'] != null
          ? DateTime.parse(json['accepted_at'])
          : null,
      photoUrls:
          (json['photo_urls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  // ===================== toJson (لو احتجتها) =====================
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'title': title,
      'description': description,
      'status': status.name,
      'priority': priority.name,
      'public_area': publicArea,
      'availability': availability,
      'full_address': fullAddress,
      'latitude': latitude,
      'longitude': longitude,
      'contact_name': contactName,
      'contact_phone': contactPhone,
      'photo_urls': photoUrls,
    };
    if (id.isNotEmpty) {
      data['id'] = id;
    }

    if (workerId != null && workerId!.isNotEmpty) {
      data['worker_id'] = workerId;
    }

    if (createdAt != null) {
      data['created_at'] = createdAt!.toIso8601String();
    }

    return data;
  }

  Order copyWith({
    String? id,
    String? title,
    String? description,
    OrderStatus? status,
    OrderPriority? priority,
    String? workerId,
    String? publicArea,
    List<Map<String, dynamic>>? availability,
    String? fullAddress,
    double? latitude,
    double? longitude,
    String? contactName,
    String? contactPhone,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? acceptedAt,
    List<String>? photoUrls,
  }) {
    return Order(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      workerId: workerId ?? this.workerId,
      publicArea: publicArea ?? this.publicArea,
      availability: availability ?? this.availability,
      fullAddress: fullAddress ?? this.fullAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      photoUrls: photoUrls ?? this.photoUrls,
    );
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

// OrderType _typeFromString(String value) {
//   return OrderType.values.firstWhere(
//     (e) => e.name == value,
//     orElse: () => OrderType.pickup,
//   );
// }

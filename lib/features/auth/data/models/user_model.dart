import 'package:moamen_project/core/utils/supabase_text.dart';

class UserModel {
  final String id;
  final String phone;
  final String? name;
  final String role; // 'admin' or 'user'
  final int maxOrders;
  final String? imageUrl;
  final DateTime createdAt;
  final bool isActive;

  UserModel({
    required this.id,
    required this.phone,
    this.name,
    required this.role,
    this.maxOrders = 5,
    this.imageUrl,
    required this.createdAt,
    required this.isActive,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      id: data[SupabaseProfileCulomns.id]?.toString() ?? '',
      phone: data[SupabaseProfileCulomns.phone] ?? '',
      name: data[SupabaseProfileCulomns.name],
      role: data[SupabaseProfileCulomns.role] ?? 'user',
      maxOrders: data[SupabaseProfileCulomns.maxOrders] ?? 5,
      imageUrl: data[SupabaseProfileCulomns.imageUrl],
      createdAt: data[SupabaseProfileCulomns.createdAt] != null
          ? DateTime.parse(data[SupabaseProfileCulomns.createdAt])
          : DateTime.now(),
      isActive: data[SupabaseProfileCulomns.isActive] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      SupabaseProfileCulomns.phone: phone,
      SupabaseProfileCulomns.name: name,
      SupabaseProfileCulomns.role: role,
      SupabaseProfileCulomns.maxOrders: maxOrders,
      SupabaseProfileCulomns.imageUrl: imageUrl,
      SupabaseProfileCulomns.createdAt: createdAt.toIso8601String(),
      SupabaseProfileCulomns.isActive: isActive,
    };
  }

  UserModel copyWith({
    String? id,
    String? phone,
    String? name,
    String? role,
    int? maxOrders,
    String? imageUrl,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      role: role ?? this.role,
      maxOrders: maxOrders ?? this.maxOrders,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

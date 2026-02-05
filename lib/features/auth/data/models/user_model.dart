import 'package:moamen_project/core/utils/supabase_text.dart';

class UserModel {
  final String id;
  final String phone;
  final String? name;
  final String role; // 'admin' or 'user'
  final int maxOrders;
  final DateTime createdAt;
  final bool isActive;

  UserModel({
    required this.id,
    required this.phone,
    this.name,
    required this.role,
    this.maxOrders = 5,
    required this.createdAt,
    required this.isActive,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      id: data[SupabaseAccountsCulomns.id]?.toString() ?? '',
      phone: data[SupabaseAccountsCulomns.phone] ?? '',
      name: data[SupabaseAccountsCulomns.name],
      role: data[SupabaseAccountsCulomns.role] ?? 'user',
      maxOrders: data[SupabaseAccountsCulomns.maxOrders] ?? 5,
      createdAt: data[SupabaseAccountsCulomns.createdAt] != null
          ? DateTime.parse(data[SupabaseAccountsCulomns.createdAt])
          : DateTime.now(),
      isActive: data[SupabaseAccountsCulomns.isActive] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      SupabaseAccountsCulomns.phone: phone,
      SupabaseAccountsCulomns.name: name,
      SupabaseAccountsCulomns.role: role,
      SupabaseAccountsCulomns.maxOrders: maxOrders,
      SupabaseAccountsCulomns.createdAt: createdAt,
      SupabaseAccountsCulomns.isActive: isActive,
    };
  }
}

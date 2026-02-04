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
      id: data[SupabaseCulomns.id]?.toString() ?? '',
      phone: data[SupabaseCulomns.phone] ?? '',
      name: data[SupabaseCulomns.name],
      role: data[SupabaseCulomns.role] ?? 'user',
      maxOrders: data[SupabaseCulomns.maxOrders] ?? 5,
      createdAt: data[SupabaseCulomns.createdAt] != null
          ? DateTime.parse(data[SupabaseCulomns.createdAt])
          : DateTime.now(),
      isActive: data[SupabaseCulomns.isActive] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      SupabaseCulomns.phone: phone,
      SupabaseCulomns.name: name,
      SupabaseCulomns.role: role,
      SupabaseCulomns.maxOrders: maxOrders,
      SupabaseCulomns.createdAt: createdAt,
      SupabaseCulomns.isActive: isActive,
    };
  }
}

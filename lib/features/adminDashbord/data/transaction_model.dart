import 'package:moamen_project/core/utils/supabase_text.dart';
import 'package:moamen_project/features/auth/data/models/user_model.dart';
import 'package:moamen_project/features/orders/data/models/order_model.dart';

class TransactionModel {
  final String id;
  final String userId;
  final int amount;
  final int balanceBefore;
  final int balanceAfter;
  final String? idempotencyKey;
  final String
  type; // one of TransactionType.purchase/adminAdd/adminRemove/usage
  final DateTime createdAt;

  // Joined Data
  final UserModel? userProfile;
  final UserModel? adminProfile;
  final Order? order;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.type,
    this.idempotencyKey,
    required this.createdAt,
    this.userProfile,
    this.adminProfile,
    this.order,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map[SupabaseOrderTransactionsCulomns.id],
      userId: map[SupabaseOrderTransactionsCulomns.userId] ?? '',
      amount: map[SupabaseOrderTransactionsCulomns.amount],
      balanceBefore: map[SupabaseOrderTransactionsCulomns.balanceBefore],
      balanceAfter: map[SupabaseOrderTransactionsCulomns.balanceAfter],
      type: map[SupabaseOrderTransactionsCulomns.type] as String,
      idempotencyKey:
          map[SupabaseOrderTransactionsCulomns.idempotencyKey] as String?,
      createdAt: DateTime.parse(
        map[SupabaseOrderTransactionsCulomns.createdAt],
      ),
      userProfile: map['user_profile'] == null
          ? null
          : UserModel.fromMap(map['user_profile']),
      adminProfile: map['admin_profile'] == null
          ? null
          : UserModel.fromMap(map['admin_profile']),
      order: map['order'] == null ? null : Order.fromJson(map['order']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      SupabaseOrderTransactionsCulomns.id: id,
      SupabaseOrderTransactionsCulomns.userId: userId,
      SupabaseOrderTransactionsCulomns.amount: amount,
      SupabaseOrderTransactionsCulomns.type: type,
      SupabaseOrderTransactionsCulomns.balanceBefore: balanceBefore,
      SupabaseOrderTransactionsCulomns.balanceAfter: balanceAfter,
      SupabaseOrderTransactionsCulomns.idempotencyKey: idempotencyKey,
      SupabaseOrderTransactionsCulomns.createdAt: createdAt.toIso8601String(),
    };
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moamen_project/core/utils/supabase_text.dart';
import 'package:moamen_project/features/adminDashbord/data/transaction_model.dart';
import 'package:moamen_project/features/adminDashbord/presentation/controller/admin_state.dart';
import 'package:moamen_project/features/auth/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminNotifier extends Notifier<AdminState> {
  final _supabase = Supabase.instance.client;

  @override
  AdminState build() =>
      AdminState(isLoading: false, users: [], error: '', transactions: []);

  // Filtered Users List
  List<UserModel> get filteredUsers {
    List<UserModel> filtered = List.from(state.users);

    // Search
    if (state.searchQuery.isNotEmpty) {
      filtered = filtered.where((user) {
        final query = state.searchQuery.toLowerCase();
        return (user.name?.toLowerCase().contains(query) ?? false) ||
            user.phone.contains(query);
      }).toList();
    }

    // Role Filter
    if (state.filterRole != null) {
      filtered = filtered
          .where((user) => user.role == state.filterRole)
          .toList();
    }

    // Status Filter
    if (state.filterStatus != null) {
      filtered = filtered
          .where((user) => user.isActive == state.filterStatus)
          .toList();
    }

    // Sorting
    if (state.sortBy == 'created_at') {
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else if (state.sortBy == 'name') {
      filtered.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
    }

    return filtered;
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setFilterRole(String? role) {
    if (role == null) {
      state = state.copyWith(clearRole: true);
    } else {
      state = state.copyWith(filterRole: role);
    }
  }

  void setFilterStatus(bool? isActive) {
    if (isActive == null) {
      state = state.copyWith(clearStatus: true);
    } else {
      state = state.copyWith(filterStatus: isActive);
    }
  }

  void setSortBy(String sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }

  // get transactions
  Future<void> fetchTransactions() async {
    state = state.copyWith(isLoading: true, error: '');
    try {
      final response = await _supabase
          .from(SupabaseTables.orderTransactions)
          .select('''
          id, created_at, type, amount, balance_before, balance_after,
          idempotency_key, user_id, admin_id, order_id,
          user_profile:profiles!order_transactions_user_profile_fkey(id, name, phone, role, image_url),
          admin_profile:profiles!order_transactions_admin_id_fkey(id, name, phone, role, image_url),
          order:orders!order_transactions_order_id_fkey(id, title, status, accepted_at, worker_id, description, priority, public_area, availability)
        ''')
          .order('created_at', ascending: false)
          .limit(200);

      final transactions = (response as List)
          .map((e) => TransactionModel.fromMap(e as Map<String, dynamic>))
          .toList();

      state = state.copyWith(transactions: transactions, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  // جلب كل اليوزرز
  Future<void> fetchUsers() async {
    state = state.copyWith(isLoading: true, error: '');
    try {
      final response = await _supabase.from(SupabaseTables.profiles).select();
      final users = (response as List).map((e) {
        // // The phone was stored as email prefix, we extract it using FakeEmail
        // // if (e['email'] != null) {
        // e[SupabaseProfileCulomns.phone] =
        //     PhoneToEmailConverter.reutrnPhoneFromEmailWithoutCountryCode(
        //       e[SupabaseProfileCulomns.phone],
        //     );
        // // }
        return UserModel.fromMap(e);
      }).toList();
      state = state.copyWith(users: users, isLoading: false);
    } catch (e) {
      print('error in fetchUsers $e');
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  // حذف يوزر
  Future<void> deleteUser(String adminId, String targetId) async {
    state = state.copyWith(isLoading: true, error: '');
    try {
      await _supabase.from(SupabaseTables.profiles).delete().eq('id', targetId);
      await fetchUsers();
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> updateUser(String targetId, UserModel updatedUser) async {
    state = state.copyWith(isLoading: true, error: '');

    try {
      final idx = state.users.indexWhere((u) => u.id == targetId);
      if (idx == -1) {
        state = state.copyWith(
          isLoading: false,
          error: 'User not found in state',
        );
        return;
      }

      final oldUser = state.users[idx];
      final int delta = updatedUser.maxOrders - oldUser.maxOrders;

      // لو مفيش تغيير في الرصيد، حدّث باقي البيانات مباشرة (name/phone/active…)
      // بس خلي max_orders مايتبعتش هنا
      final profileUpdateMap = updatedUser.toMap()..remove('max_orders');

      // 1) حدّث بيانات البروفايل العامة (بدون max_orders)
      if (profileUpdateMap.isNotEmpty) {
        await _supabase
            .from(SupabaseTables.profiles)
            .update(profileUpdateMap)
            .eq('id', targetId);
      }

      // 2) لو فيه تعديل رصيد، استخدم RPC واحدة (هي اللي تسجل transaction + تعدل max_orders)
      if (delta != 0) {
        final idempotencyKey =
            'admin_ui:${targetId}:${DateTime.now().millisecondsSinceEpoch}';

        final res = await _supabase.rpc(
          SupabaseFunctions.adminAdjustMaxOrders,
          params: {
            'p_target_user_id': targetId,
            'p_delta': delta,
            'p_reason': 'Admin dashboard update',
            'p_idempotency_key': idempotencyKey,
          },
        );

        // لو الفنكشن بتعمل return integer (new balance)
        final int? newBalance = res is int
            ? res
            : int.tryParse(res?.toString() ?? '');

        if (newBalance != null) {
          updatedUser = updatedUser.copyWith(maxOrders: newBalance);
        }
      }

      // 3) Update local state بدل fetchUsers (أقل requests)
      final newUsers = [...state.users];
      newUsers[idx] = updatedUser;

      state = state.copyWith(isLoading: false, users: newUsers);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

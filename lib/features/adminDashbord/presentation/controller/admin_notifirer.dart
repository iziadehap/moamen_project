import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moamen_project/core/utils/supabase_text.dart';
import 'package:moamen_project/features/adminDashbord/presentation/controller/admin_state.dart';
import 'package:moamen_project/features/auth/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminNotifier extends Notifier<AdminState> {
  final _supabase = Supabase.instance.client;

  @override
  AdminState build() => AdminState(isLoading: false, users: [], error: '');

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

  // جلب كل اليوزرز (ده شغال عادي)
  Future<void> fetchUsers() async {
    state = state.copyWith(isLoading: true, error: '');
    try {
      final response = await _supabase.from(SupabaseTables.accounts).select();
      final users = (response as List)
          .map((e) => UserModel.fromMap(e))
          .toList();
      state = state.copyWith(users: users, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  // حذف يوزر
  Future<void> deleteUser(String adminId, String targetId) async {
    state = state.copyWith(isLoading: true, error: '');
    try {
      final result = await _supabase.rpc(
        'admin_delete_account',
        params: {'p_admin_id': adminId, 'p_target_id': targetId},
      );

      if (result == 'تم حذف الحساب بنجاح') {
        await fetchUsers();
      } else {
        state = state.copyWith(error: result, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  // تعديل يوزر
  Future<void> updateUser(
    String adminId,
    String targetId,
    UserModel updatedUser,
  ) async {
    state = state.copyWith(isLoading: true, error: '');
    try {
      final result = await _supabase.rpc(
        'admin_update_account',
        params: {
          'p_admin_id': adminId,
          'p_target_id': targetId,
          'p_data': updatedUser.toMap(), // UserModel.toMap() لازم يكون موجود
        },
      );

      if (result == 'تم تعديل الحساب بنجاح' ||
          result.toString().contains('بنجاح')) {
        await fetchUsers();
      } else {
        state = state.copyWith(error: result.toString(), isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

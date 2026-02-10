import 'package:moamen_project/features/auth/data/models/user_model.dart';

class AdminState {
  final bool isLoading;
  final List<UserModel> users;
  final String error;
  final String? filterRole;
  final bool? filterStatus; // true: active, false: disabled, null: all
  final String searchQuery;
  final String sortBy; // 'created_at', 'name'

  AdminState({
    required this.isLoading,
    required this.users,
    required this.error,
    this.filterRole,
    this.filterStatus,
    this.searchQuery = '',
    this.sortBy = 'created_at',
  });

  AdminState copyWith({
    bool? isLoading,
    List<UserModel>? users,
    String? error,
    String? filterRole,
    bool clearRole = false,
    bool? filterStatus,
    bool clearStatus = false,
    String? searchQuery,
    String? sortBy,
  }) {
    return AdminState(
      isLoading: isLoading ?? this.isLoading,
      users: users ?? this.users,
      error: error ?? this.error,
      filterRole: clearRole ? null : (filterRole ?? this.filterRole),
      filterStatus: clearStatus ? null : (filterStatus ?? this.filterStatus),
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

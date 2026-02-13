import '../../data/models/user_model.dart';

class AppAuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  const AppAuthState({this.user, this.isLoading = false, this.error});

  bool get isAuthenticated => user != null;
  bool get isActive => user?.isActive == true;

  AppAuthState copyWith({UserModel? user, bool? isLoading, String? error}) {
    return AppAuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  AppAuthState clearError() {
    return AppAuthState(user: user, isLoading: isLoading, error: null);
  }

  AppAuthState clearUser() {
    return const AppAuthState();
  }
}

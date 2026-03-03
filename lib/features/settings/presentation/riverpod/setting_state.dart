class SettingState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  const SettingState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  SettingState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return SettingState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

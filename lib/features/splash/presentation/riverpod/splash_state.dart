class SplashState {
  final bool internetChecked;
  final bool gpsChecked;
  final double progress;
  final String? error;
  final dynamic solveError;

  const SplashState({
    this.internetChecked = false,
    this.gpsChecked = false,
    this.progress = 0.0,
    this.error,
    this.solveError,
  });

  SplashState copyWith({
    bool? internetChecked,
    bool? gpsChecked,
    double? progress,
    String? error,
    dynamic? solveError,
  }) {
    return SplashState(
      internetChecked: internetChecked ?? this.internetChecked,
      gpsChecked: gpsChecked ?? this.gpsChecked,
      progress: progress ?? this.progress,
      error: error,
      solveError: solveError,
    );
  }
}

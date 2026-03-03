import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Connectivity state
class ConnectivityState {
  final ConnectivityResult status;
  final bool showNoInternetMessage;
  final bool isChecking;
  final bool isEnabled;

  const ConnectivityState({
    required this.status,
    this.showNoInternetMessage = false,
    this.isChecking = false,
    this.isEnabled = false,
  });

  ConnectivityState copyWith({
    ConnectivityResult? status,
    bool? showNoInternetMessage,
    bool? isChecking,
    bool? isEnabled,
  }) {
    return ConnectivityState(
      status: status ?? this.status,
      showNoInternetMessage:
          showNoInternetMessage ?? this.showNoInternetMessage,
      isChecking: isChecking ?? this.isChecking,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  bool get isConnected => !isChecking && status != ConnectivityResult.none;
}

// Connectivity Notifier
class ConnectivityNotifier extends Notifier<ConnectivityState> {
  final Connectivity _connectivity = Connectivity();

  @override
  ConnectivityState build() {
    _initConnectivity();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    return const ConnectivityState(
      status: ConnectivityResult.none,
      isEnabled: false,
      isChecking: true,
    );
  }

  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      print('Could not check connectivity status: $e');
    }
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    state = state.copyWith(
      isChecking: false,
      status: result,
      showNoInternetMessage: result == ConnectivityResult.none,
    );
  }

  void dismissNoInternetMessage() {
    state = state.copyWith(showNoInternetMessage: false);
  }

  void enable() {
    state = state.copyWith(isEnabled: true, status: ConnectivityResult.wifi);
  }
}

// Provider
final connectivityProvider =
    NotifierProvider<ConnectivityNotifier, ConnectivityState>(
      ConnectivityNotifier.new,
    );

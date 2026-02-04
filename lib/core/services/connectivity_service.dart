import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Connectivity state
class ConnectivityState {
  final ConnectivityResult status;
  final bool showNoInternetMessage;
  final bool isChecking;

  const ConnectivityState({
    required this.status,
    this.showNoInternetMessage = false,
    this.isChecking = true,
  });

  ConnectivityState copyWith({
    ConnectivityResult? status,
    bool? showNoInternetMessage,
    bool? isChecking,
  }) {
    return ConnectivityState(
      status: status ?? this.status,
      showNoInternetMessage:
          showNoInternetMessage ?? this.showNoInternetMessage,
      isChecking: isChecking ?? this.isChecking,
    );
  }

  bool get isConnected => !isChecking && status != ConnectivityResult.none;
}

// Connectivity Notifier
class ConnectivityNotifier extends Notifier<ConnectivityState> {
  final Connectivity _connectivity = Connectivity();

  @override
  ConnectivityState build() {
    // Start with wifi as default to avoid false "no internet" message
    // The actual status will be updated immediately by _initConnectivity
    _initConnectivity();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    return const ConnectivityState(status: ConnectivityResult.wifi);
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
    state = ConnectivityState(
      status: result,
      showNoInternetMessage: result == ConnectivityResult.none,
      isChecking: false,
    );
  }

  void dismissNoInternetMessage() {
    state = state.copyWith(showNoInternetMessage: false);
  }
}

// Provider
final connectivityProvider =
    NotifierProvider<ConnectivityNotifier, ConnectivityState>(
      ConnectivityNotifier.new,
    );

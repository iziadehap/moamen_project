import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../permission_service.dart';

// Location state
class LocationState {
  final Position? position;
  final String? error;
  final bool isLoading;
  final bool isChecking;
  final bool isEnabled;

  const LocationState({
    this.position,
    this.error,
    this.isLoading = false,
    this.isChecking = false,
    this.isEnabled = false,
  });

  LocationState copyWith({
    Position? position,
    String? error,
    bool? isLoading,
    bool? isChecking,
    bool? isEnabled,
  }) {
    return LocationState(
      position: position ?? this.position,
      error: error,
      isLoading: isLoading ?? this.isLoading,
      isChecking: isChecking ?? this.isChecking,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}

// Location Notifier
class LocationNotifier extends Notifier<LocationState> {
  late final PermissionService _permissionService;

  @override
  LocationState build() {
    _permissionService = ref.read(permissionServiceProvider);

    // Listen to location service status changes (GPS on/off)
    Geolocator.getServiceStatusStream().listen((status) {
      if (status == ServiceStatus.disabled) {
        state = state.copyWith(error: 'Location services disabled');
      } else {
        // If enabled, refresh location
        _getCurrentLocation();
      }
    });

    Future.microtask(() => _getCurrentLocation());
    return const LocationState(isEnabled: false);
  }

  Future<void> _getCurrentLocation() async {
    state = state.copyWith(isLoading: true);

    final hasPermission = await _permissionService
        .checkAndRequestLocationPermission();
    if (!hasPermission) {
      state = state.copyWith(
        error: 'Location permission denied',
        isLoading: false,
      );
      return;
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      state = state.copyWith(
        error: 'Location services disabled',
        isLoading: false,
      );
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );
      state = state.copyWith(
        position: position,
        isChecking: true,
        error: null,
        isLoading: false,
      );
    } catch (e) {
      print('Error getting location: $e');
      state = state.copyWith(
        error: 'Failed to get location: $e',
        isLoading: false,
      );
    }
  }

  Future<void> refreshLocation() async {
    await _getCurrentLocation();
    state = state.copyWith(isChecking: false);
  }

  // Utility method for distance calculation
  double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  void enable() {
    state = state.copyWith(isEnabled: true);
    // Trigger a check when enabled
    _getCurrentLocation();
  }
}

// Providers
final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionService();
});

final locationProvider = NotifierProvider<LocationNotifier, LocationState>(
  LocationNotifier.new,
);

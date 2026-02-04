import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'permission_service.dart';

// Location state
class LocationState {
  final Position? position;
  final String? error;
  final bool isLoading;

  const LocationState({this.position, this.error, this.isLoading = false});

  LocationState copyWith({Position? position, String? error, bool? isLoading}) {
    return LocationState(
      position: position ?? this.position,
      error: error,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Location Notifier
class LocationNotifier extends Notifier<LocationState> {
  late final PermissionService _permissionService;

  @override
  LocationState build() {
    _permissionService = ref.read(permissionServiceProvider);
    _getCurrentLocation();
    return const LocationState();
  }

  Future<void> _getCurrentLocation() async {
    state = state.copyWith(isLoading: true);

    final hasPermission = await _permissionService
        .checkAndRequestLocationPermission();
    if (!hasPermission) {
      state = LocationState(error: 'Location permission denied');
      return;
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      state = LocationState(error: 'Location services disabled');
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      state = LocationState(position: position);
    } catch (e) {
      print('Error getting location: $e');
      state = LocationState(error: 'Failed to get location: $e');
    }
  }

  Future<void> refreshLocation() async {
    await _getCurrentLocation();
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
}

// Providers
final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionService();
});

final locationProvider = NotifierProvider<LocationNotifier, LocationState>(
  LocationNotifier.new,
);

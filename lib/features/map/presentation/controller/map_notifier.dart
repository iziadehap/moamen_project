import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:moamen_project/features/auth/presentation/controller/auth_provider.dart';
import 'package:moamen_project/features/map/data/datasources/map_datasources.dart';
import 'package:moamen_project/features/map/data/map_model.dart';
import 'package:moamen_project/features/map/data/map_reboimp.dart';
import 'package:moamen_project/features/map/domain/mapUsecase/map_getOrders.dart';
import 'package:moamen_project/features/map/domain/mapUsecase/map_sort.dart';
import 'package:moamen_project/features/map/presentation/controller/map_state.dart';

class MapNotifier extends Notifier<MapState> {
  StreamSubscription<Position>? _locationSubscription;

  @override
  MapState build() {
    ref.onDispose(() {
      _locationSubscription?.cancel();
    });
    return MapState(
      isLoding: false,
      mapModel: MapModel(userPoints: [], publicPoints: []),
      errorMassage: "",
      userLocation: const LatLng(30.0444, 31.2357), // Default Cairo
      showPublicCircles: true,
    );
  }

  Future<void> initLocationService() async {
    try {
      // Check permissions
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled don't continue
        // accessing the position and request users of the
        // App to enable the location services.
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Default location is already set in build
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (state.userLocation != null &&
          position.latitude == state.userLocation!.latitude &&
          position.longitude == state.userLocation!.longitude) {
        // No change
      } else {
        state = state.copyWith(
          userLocation: LatLng(position.latitude, position.longitude),
        );
      }

      // Listen to location changes
      _locationSubscription?.cancel();
      _locationSubscription =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 10,
            ),
          ).listen(
            (Position position) {
              state = state.copyWith(
                userLocation: LatLng(position.latitude, position.longitude),
              );
            },
            onError: (e) {
              // Handle stream error gracefully
              print("Location stream error: $e");
            },
          );
    } catch (e) {
      // Keep default, log error if possible
      print("Error in initLocationService: $e");
    }
  }

  void togglePublicCircles() {
    state = state.copyWith(showPublicCircles: !state.showPublicCircles);
  }

  Future<void> getOrders() async {
    state = state.copyWith(isLoding: true);
    // get user data
    final authState = ref.read(authProvider);
    final user = authState.user;
    if (user == null) {
      state = state.copyWith(isLoding: false, errorMassage: "User not found");
      return;
    }

    // get orders
    final mapDatasources = MapDatasources();
    final mapRebo = MapReboImp(mapDatasources: mapDatasources);
    final mapUsecase = GetOrders(mapRebo: mapRebo);
    final result = await mapUsecase.call(user);

    result.fold(
      (failure) {
        state = state.copyWith(isLoding: false, errorMassage: failure.message);
      },
      (mapModel) async {
        // If we have user location, sort by it. Otherwise just set model.
        if (state.userLocation != null) {
          sortOrdersByLocation(state.userLocation!, mapModel);
        } else {
          state = state.copyWith(isLoding: false, mapModel: mapModel);
        }
      },
    );
  }

  Future<void> sortOrdersByLocation(LatLng location, MapModel mapModel) async {
    // Note: Use copyWith to ensure we don't lose other state
    // state = state.copyWith(isLoding: true);
    // Commented out loading here as it might flicker if called frequently,
    // map sorting should be fast. But if needed, uncomment.

    final mapDatasources = MapDatasources();
    final mapRebo = MapReboImp(mapDatasources: mapDatasources);
    final mapUsecase = SortOrdersByLocation(mapRebo: mapRebo);
    final result = await mapUsecase.call(location, mapModel);

    result.fold(
      (failure) {
        state = state.copyWith(isLoding: false, errorMassage: failure.message);
      },
      (sortedMapModel) {
        state = state.copyWith(isLoding: false, mapModel: sortedMapModel);
      },
    );
  }
}

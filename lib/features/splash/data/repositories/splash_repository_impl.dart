import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moamen_project/core/services/location/location_service.dart';
import 'package:moamen_project/features/splash/domain/repositories/splash_repository.dart';
import '../../../../core/services/connectivity/connectivity_service.dart';
import '../../../../core/utils/cash.dart';

class SplashRepositoryImpl implements SplashRepository {
  final Ref ref;

  SplashRepositoryImpl(this.ref);

  @override
  Future<bool> checkConnectivity() async {
    final connectivityState = ref.read(connectivityProvider);
    if (!connectivityState.isChecking && connectivityState.isConnected) {
      return true;
    }
    return connectivityState.isConnected;
  }

  @override
  Future<bool> checkLocationPermission() async {
    final permissionService = ref.read(permissionServiceProvider);
    return await permissionService.checkAndRequestLocationPermission();
  }

  @override
  Future<bool> checkLocationService() async {
    final permissionService = ref.read(permissionServiceProvider);
    return await permissionService.isLocationServiceEnabled();
  }

  @override
  Future<Map<String, String?>> getSavedCredentials() async {
    return await PrivcyCash.readCredentials();
  }
}

final splashRepositoryProvider = Provider<SplashRepository>((ref) {
  return SplashRepositoryImpl(ref);
});

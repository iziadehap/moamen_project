abstract class SplashRepository {
  Future<bool> checkConnectivity();
  Future<bool> checkLocationPermission();
  Future<bool> checkLocationService();
  // Future<Map<String, String?>> getSavedCredentials();
}

import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<PermissionStatus>? _locationRequestFuture;

  Future<bool> checkAndRequestLocationPermission() async {
    // If a request is already in progress, wait for it
    if (_locationRequestFuture != null) {
      final status = await _locationRequestFuture!;
      return status.isGranted;
    }

    var status = await Permission.location.status;
    if (status.isDenied) {
      try {
        _locationRequestFuture = Permission.location.request();
        status = await _locationRequestFuture!;
      } finally {
        _locationRequestFuture = null;
      }
    }

    if (status.isPermanentlyDenied) {
      return false;
    }

    return status.isGranted;
  }

  Future<bool> isLocationServiceEnabled() async {
    return await Permission.location.serviceStatus.isEnabled;
  }
}

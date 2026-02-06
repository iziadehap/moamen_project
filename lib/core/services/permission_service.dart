import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> checkAndRequestLocationPermission() async {
    var status = await Permission.location.status;
    if (status.isDenied) {
      status = await Permission.location.request();
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

import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> checkAndRequestLocationPermission() async {
    var status = await Permission.location.status;
    if (status.isDenied) {
      print("status.isDenied");
      status = await Permission.location.request();
    }

    if (status.isPermanentlyDenied) {
      print("status.isPermanentlyDenied");
      openAppSettings();
      return false;
    }

    return status.isGranted;
  }
}

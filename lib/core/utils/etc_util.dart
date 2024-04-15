import 'package:permission_handler/permission_handler.dart';

Future<bool> getPermissionStatus(Permission permission) async {
  PermissionStatus status = await permission.status;
  if (status.isGranted) {
    return true;
  } else if (status.isDenied) {
    requestPermission(permission);
  } else if (status.isPermanentlyDenied) {
    openAppSettings();
  } else if (status.isRestricted) {
    requestPermission(permission);
  } else {}
  return false;
}

// Request the permission
void requestPermission(Permission permission) async {
  PermissionStatus status = await permission.request();
  if (status.isPermanentlyDenied) {
    openAppSettings();
  }
}

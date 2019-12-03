import 'package:permission_handler/permission_handler.dart';

class PermissionsService {
  final PermissionHandler _permissionHandler = PermissionHandler();

  Future<bool> _requestPermission(PermissionGroup permission) async {
    var result = await _permissionHandler.requestPermissions([permission]);
    if (result[permission] == PermissionStatus.granted) {
      return true;
    }
    return false;
  }

  /// Requests the users permission to use camera.
  Future<bool> requestCameraPermission({Function onPermissionDenied}) async {
    var granted = await _requestPermission(PermissionGroup.camera);
    if (!granted) {
      // onPermissionDenied();
    }
    return granted;
  }

  /// Requests the users permission to use microphone.
  Future<bool> requestMicrophonePermission({Function onPermissionDenied}) async {
    var granted = await _requestPermission(PermissionGroup.microphone);
    if (!granted) {
      // onPermissionDenied();
    }
    return granted;
  }

  /// Requests the users permission to use storage.
  Future<bool> requestStoragePermission({Function onPermissionDenied}) async {
    var granted = await _requestPermission(PermissionGroup.storage);
    if (!granted) {
      // onPermissionDenied();
    }
    return granted;
  }

  // /// Requests the users permission to read their location when the app is in use
  // Future<bool> requestLocationPermission() async {
  //   return _requestPermission(PermissionGroup.locationWhenInUse);
  // }

}
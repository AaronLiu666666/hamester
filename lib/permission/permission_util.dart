import 'package:permission_handler/permission_handler.dart';

Future<bool>  requestPermission(Permission permission) async {
  if (await permission.isGranted) {
    return true;
  } else {
    var result = await permission.request();
    if (result == PermissionStatus.granted) {
      return true;
    }
  }
  return false;
}

///请求权限
Future<bool> requestPermissionDefault() async {
  // bool isMore13 = await SystemUtil.isMoreAndroid13();
  // bool storagePermission = isMore13 ? true : await Permission.storage.isGranted;
  bool storagePermission =  await Permission.storage.isGranted;
  bool manageExternal = await Permission.manageExternalStorage.isGranted;

  if (!storagePermission) {
    storagePermission = await Permission.storage.request().isGranted;
  }

  if (!manageExternal) {
    manageExternal = await Permission.manageExternalStorage.request().isGranted;
  }

  bool isPermissionGranted = storagePermission && manageExternal;

  if (isPermissionGranted) {
    return true;
  } else {
    return false;
  }
}


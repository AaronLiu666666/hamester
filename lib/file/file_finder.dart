import 'dart:async';
import 'dart:io';
import 'package:app_settings/app_settings.dart';
import 'package:device_info/device_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:android_intent/android_intent.dart';

import '../permission/permission_util.dart';

class FileFinder {
  static Future<List<File>> findVideoFiles() async {
    final plugin = DeviceInfoPlugin();
    final android = await plugin.androidInfo;
    // 请求外部存储权限
    // final storageStatus = android.version.sdkInt < 33
    //     ? await requestPermission(Permission.storage)
    //     : PermissionStatus.granted;

    // 检查是否已经有存储权限
    // var status = await Permission.storage.status;
    // if (storageStatus == PermissionStatus.granted) {
    //   print("granted");
    // }
    // if (storageStatus == PermissionStatus.denied) {
    //   print("denied");
    // }
    // bool storageStatus = await requestStoragePermission();
    bool storageStatus = true;
    List<File> videoFiles = [];


    if (storageStatus) {
      // 获取外部存储目录（通常是/sdcard）
      Directory? externalStorageDir = await getExternalStorageDirectory();
      if (externalStorageDir != null) {
        print('App External Directory: ${externalStorageDir.path}');
        // 构建Downloads目录路径
        // String downloadsDir = '${externalStorageDir.path}/Download';
        String downloadsDir = '/storage/emulated/0/Pictures';
        List<File>? files = findFiles(Directory(downloadsDir));

        // 构建文件路径列表
        if (files != null && files.isNotEmpty) {
          for (File file in files) {
            videoFiles.add(file);
          }
        }
      }
    } else {
      // 处理权限被拒绝的情况
      print('权限被拒绝');
    }

    return videoFiles;
  }

  static List<File>? findFiles(Directory directory) {
    List<File> files = [];

    // 遍历目录
    // directory.listSync(recursive: true).forEach((FileSystemEntity entity) {
    //   // 检查是否是文件
    //   if (entity is File) {
    //     // 检查文件扩展名，这里假设视频文件的扩展名为.mp4，可以根据实际情况修改
    //     if (entity.path.toLowerCase().endsWith('.mp4')) {
    //       files.add(entity);
    //     }
    //   }
    // });
    // 异步遍历目录
    for (var entity in listFiles(directory)) {
      // 检查是否是文件
      if (entity is File) {
        // 检查文件扩展名
        if (entity.path.toLowerCase().endsWith('.mp4')) {
          files.add(entity);
        }
      }
    }

    return files.isNotEmpty ? files : null;
  }

  static Iterable<FileSystemEntity> listFiles(Directory directory) sync* {
    for (var entity in directory.listSync(recursive: true)) {
      yield entity;
    }
  }
}

Future<bool> requestStoragePermission() async {
  // 检查是否已经有存储权限
  var status = await Permission.storage.status;

  // await AppSettings.openAppSettings();
  if(status.isPermanentlyDenied){
    await AppSettings.openAppSettings();
  } else {
    await Permission.storage.request();
  }

  if (status.isGranted) {
    // 已经获得权限，可以执行存储操作
    print('已经获得存储权限');
    return true;
  } else {
    // 如果没有权限，请求权限
    var result = await Permission.storage.request();
    if (result.isGranted) {
      // 用户同意授予权限
      print('用户同意存储权限');
      // 在这里执行相应的操作
      return true;
    } else {
      // 用户拒绝或永久拒绝存储权限
      print('用户拒绝或永久拒绝存储权限');
      return false;
    }
  }





}
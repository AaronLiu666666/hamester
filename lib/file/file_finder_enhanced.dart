import 'dart:io';
import 'dart:async';

import 'package:path_provider/path_provider.dart';

// 找视频文件
List<File> findVideoFiles(Directory directory) {
  List<File> videoFiles = [];

  void search(Directory dir) {
    dir.listSync().forEach((FileSystemEntity entity) {
      if (entity is File) {
        print(entity.path);
        if (entity.path.toLowerCase().endsWith('.mp4')) {
          videoFiles.add(entity);
        }
      } else if (entity is Directory) {
        search(entity); // 递归遍历子文件夹
      }
    });
  }

  search(directory);
  return videoFiles;
}

// 异步函数，找文件并返回结果
Future<List<File>> findFilesAsync(Directory directory) async {
  return findVideoFiles(directory);
}

// 获取应用内部存储目录路径
Future<String> getInternalStorageDirectory() async {
  Directory appDocDir = await getApplicationDocumentsDirectory();
  return appDocDir.path;
}

Future<String> getExternalStoragePath() async {
  Directory? externalStorageDir = await getExternalStorageDirectory();
  if(null==externalStorageDir){
    return "";
  }
  return externalStorageDir.path;
}

Future<String> getPicStorePath() async {
  String storageDirPath = await getExternalStoragePath();
  return '$storageDirPath/pic_store/';
}
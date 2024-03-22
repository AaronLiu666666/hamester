import 'dart:io';
import 'dart:async';

import 'package:hamster/permission/permission_util.dart';

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
        // search(entity); // 递归遍历子文件夹
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

void main() async {
  Directory directory = Directory.current;
  List<File> videoFiles = await findFilesAsync(directory);
  if (videoFiles.isNotEmpty) {
    print("视频文件：");
    videoFiles.forEach((file) => print(file.path));
  } else {
    print("未找到视频文件。");
  }
}

import 'dart:io';
import 'package:crypto/crypto.dart';


String getFileDisplayName(File file) {
  return file.uri.pathSegments.last;
}

String calculateMD5(File file) {
  var content = file.readAsBytesSync();
  var md5Result = md5.convert(content);
  return md5Result.toString();
}

Future<void> deleteFile(String filePath) async {
  try {
    if(filePath.isEmpty){
      print("文件路径为空");
      return;
    }
    File file = File(filePath);
    if (await file.exists()) {
      await file.delete();
      // 文件删除成功后的操作
      print("文件删除成功");
    } else {
      // 文件不存在的情况处理
      print("文件不存在");
    }
  } catch (e) {
    // 处理文件删除过程中的异常情况
    print("文件删除失败");
  }
}
import 'dart:io';
import 'dart:typed_data';
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

Future<void> saveFileToLocal(File file, String localPath) async {
  try {
    // 读取文件内容
    List<int> contents = await file.readAsBytes();

    // 将文件内容写入本地文件
    File localFile = File(localPath);
    await localFile.create(recursive: true);
    await localFile.writeAsBytes(contents);

    print('文件保存成功: $localPath');
  } catch (e) {
    print('保存文件失败: $e');
  }
}

Future<void> saveUint8ListAsImage(Uint8List data, String filePath) async {
  try {
    // 创建文件
    File file = File(filePath);

    // 将 Uint8List 写入文件
    await file.writeAsBytes(data);

    print('图像文件保存成功: $filePath');
  } catch (e) {
    print('保存图像文件失败: $e');
  }
}

Future<String> calcFileSize(String path) async {
  if(path.isEmpty){
    return "";
  }
  File file = File(path);
  if(!file.existsSync()){
    return "";
  }
  int sizeInBytes = await file.length();
  double sizeInKB = sizeInBytes / 1024;
  if (sizeInKB >= 1024) {
    double sizeInMB = sizeInKB / 1024;
    if (sizeInMB >= 1024) {
      double sizeInGB = sizeInMB / 1024;
      return sizeInGB.toStringAsFixed(2) + 'GB';
    } else {
      return sizeInMB.toStringAsFixed(2) + 'MB';
    }
  } else {
    return sizeInKB.toStringAsFixed(2) + 'KB';
  }
}
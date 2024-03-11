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
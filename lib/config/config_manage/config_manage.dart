import 'package:flutter_dotenv/flutter_dotenv.dart';


class ConfigManager {

  static String getString(String key) {
    return dotenv.env[key] ?? ''; // 返回配置值，如果找不到则返回空字符串
  }

  static int getInt(String key) {
    return int.tryParse(dotenv.env[key] ?? '') ?? 0; // 返回配置值，如果找不到或者无法解析为整数则返回 0
  }

  static double getDouble(String key) {
    return double.tryParse(dotenv.env[key] ?? '') ?? 0.0; // 返回配置值，如果找不到或者无法解析为浮点数则返回 0.0
  }

  static bool getBool(String key) {
    return dotenv.env[key]?.toLowerCase() == 'true' ?? false; // 返回配置值，如果找不到或者不是 'true' 则返回 false
  }
}
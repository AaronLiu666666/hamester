import 'package:logger/logger.dart';

///lib/utils/log_util.dart
///日志输出工具类
class LogUtils {
  static final Logger _logger = Logger();

  static bool _debugMode = false;

  static void init({
    bool isDebug = false,
  }) {
    _debugMode = isDebug;
  }

  static void e(Object object) {
    _logger.e(object);
  }

  static void d(Object object) {
    if (_debugMode) {
      _logger.d(object);
    }
  }

  static void i(Object object) {
    _logger.i(object);
  }

  static void w(Object object) {
    _logger.w(object);
  }
}

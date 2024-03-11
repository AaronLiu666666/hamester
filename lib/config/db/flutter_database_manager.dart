
import 'flutter_data_base.dart';

/**
 * 数据库 manager
 *
 * flutter packages pub run build_runner build
 */
class FlutterDataBaseManager {
  static database() async {
    // g.dart 生成的 就叫 $FloorFlutterDataBase，真的是吐了，见过最麻烦的orm
    final database = await $FloorFlutterDataBase.databaseBuilder('data.db').build();
    // 其他数据库相关的操作...
    return database;

  }
}
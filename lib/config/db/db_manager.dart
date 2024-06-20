import 'package:hamster/repository/daos/brilliant_time_dao.dart';

import 'flutter_data_base.dart';
import 'flutter_database_manager.dart';

/// 数据库manager 统一管理
class DbManager {
  //单例
  static  DbManager? _singleton ;
  // 工厂构造函数，返回单例实例
  factory DbManager() => _singleton ??= DbManager._();
  // 私有构造函数
  DbManager._();
  void dispose()=>_singleton=null;
  //定义数据库变量
  late final FlutterDataBase _db;
  BrilliantTimeDao get brilliantDao => _db.brilliantDao;

  initDB() async {
    _db = await FlutterDataBaseManager.database();
  }
}

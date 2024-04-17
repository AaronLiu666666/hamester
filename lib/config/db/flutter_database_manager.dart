
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'flutter_data_base.dart';

/**
 * 数据库 manager
 *
 * flutter packages pub run build_runner build
 */
class FlutterDataBaseManager {
  static database() async {
    final externalDir = await getExternalStorageDirectory();
    final dbPath = join(externalDir!.path,'db', 'data.db');
    return await $FloorFlutterDataBase.databaseBuilder(dbPath).build();
  }
}
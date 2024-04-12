
import 'dart:async';

import 'package:floor/floor.dart';
import 'package:hamster/app_config_manage/model/po/app_config_po.dart';
import 'package:hamster/media_manage/mapper/media_file_data_dao.dart';
import 'package:hamster/media_manage/model/po/media_file_data.dart';
import 'package:hamster/tag_manage/mapper/media_tag_relation_dao.dart';
import 'package:hamster/tag_manage/mapper/tag_info_dao.dart';
import 'package:hamster/tag_manage/model/po/media_tag_relation.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import '../../app_config_manage/model/mapper/app_config_dao.dart';
import '../../tag_manage/model/po/tag_info.dart';

part "flutter_data_base.g.dart";

// @Database(version: 1, entities: [MediaFileData])
@Database(version:1, entities: [MediaFileData,TagInfo,MediaTagRelation,AppConfig])
abstract class FlutterDataBase extends FloorDatabase {

  MediaFileDataDao get mediaFileDataDao;

  TagInfoDao get tagInfoDao;

  MediaTagRelationDao get mediaTagRelationDao;

  AppConfigDao get appConfigDao;

  // 静态方法返回迁移对象
  static Migration getMigration1to2() {
    return Migration(1, 2, (database) async {
      // 创建临时表
      await database.execute('CREATE TABLE media_file_data_temp ('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'path TEXT, '
          'file_name TEXT, '
          'file_alias TEXT, '
          'file_md5 TEXT, '
          'source_url TEXT, '
          'create_time INTEGER, '
          'update_time INTEGER, '
          'memo TEXT, '
          'cover TEXT)');
      print("创建临时表成功");
      // 将数据从旧表复制到临时表
      await database.execute('INSERT INTO media_file_data_temp '
          '(id, path, file_name, file_alias, file_md5, source_url, create_time, update_time) '
          'SELECT id, path, file_name, file_alias, file_md5, source_url, create_time, update_time '
          'FROM media_file_data');
      print("将数据从旧表复制到临时表成功");

      // 删除旧表
      await database.execute('DROP TABLE media_file_data');
      print("删除旧表成功");

      // 将临时表重命名为新表
      await database.execute('ALTER TABLE media_file_data_temp RENAME TO media_file_data');
      print("将临时表重命名为新表成功");

    });
  }


}

/*

import 'package:hamster/config/db/flutter_data_base.dart';
import 'package:floor/floor.dart';

part "FlutterDataBase.g.dart";
part of "FlutterDataBase.dart";

/**
 * 数据库 manager
 *
 * flutter packages pub run build_runner build
 */
class FlutterDataBaseManager {
  static database() async {
    final database = await $FlutterDataBase.databaseBuilder('data.db').build();
    // 其他数据库相关的操作...
    return database;

  }
}
 */

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

@Database(version:1, entities: [MediaFileData,TagInfo,MediaTagRelation,AppConfig])
abstract class FlutterDataBase extends FloorDatabase {

  MediaFileDataDao get mediaFileDataDao;

  TagInfoDao get tagInfoDao;

  MediaTagRelationDao get mediaTagRelationDao;

  AppConfigDao get appConfigDao;

}

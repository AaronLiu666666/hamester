
import 'package:hamster/config/db/flutter_data_base.dart';
import 'package:hamster/config/db/flutter_database_manager.dart';
import 'package:hamster/tag_manage/model/dto/search_dto.dart';

import '../tag_manage/model/po/media_tag_relation.dart';

Future<List<MediaTagRelation>> getRelationInfo(SearchDTO) async {
  final FlutterDataBase dataBase = await FlutterDataBaseManager.database();
  List<MediaTagRelation> list = await dataBase.mediaTagRelationDao.queryAllDataList();
  return list;

}

Future<List<MediaTagRelation>> queryRelationsByTagId(String id) async {
  final FlutterDataBase dataBase = await FlutterDataBaseManager.database();
  List<MediaTagRelation> list = await dataBase.mediaTagRelationDao.queryRelationsByTagId(id);
  return list;
}
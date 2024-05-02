import 'package:hamster/config/db/data_base_provider.dart';
import 'package:hamster/config/db/flutter_data_base.dart';
import 'package:hamster/config/db/flutter_database_manager.dart';
import 'package:hamster/tag_manage/model/dto/search_dto.dart';

import '../tag_manage/model/po/media_tag_relation.dart';

Future<List<MediaTagRelation>> getRelationInfo(SearchDTO) async {
  final FlutterDataBase dataBase = await FlutterDataBaseManager.database();
  List<MediaTagRelation> list =
      await dataBase.mediaTagRelationDao.queryAllDataList();
  return list;
}

Future<List<MediaTagRelation>> getRelationInfoWithTagName(SearchDTO) async {
  final FlutterDataBase dataBase = await FlutterDataBaseManager.database();
  List<MediaTagRelation> list =
  await dataBase.mediaTagRelationDao.queryAllDataListWithTagName();
  return list;
}


Future<List<MediaTagRelation>> queryRelationsByTagId(String id) async {
  final FlutterDataBase dataBase = await FlutterDataBaseManager.database();
  List<MediaTagRelation> list =
      await dataBase.mediaTagRelationDao.queryRelationsByTagId(id);
  return list;
}

Future<List<MediaTagRelation>> queryRelationsByTagIdWithMediaPath(String id) async {
  final FlutterDataBase dataBase = await FlutterDataBaseManager.database();
  List<MediaTagRelation> list =
  await dataBase.mediaTagRelationDao.queryRelationsByTagIdWithMediaPath(id);
  return list;
}


Future<MediaTagRelation?> queryRelationById(String id) async {
  final FlutterDataBase dataBase = await FlutterDataBaseManager.database();
  MediaTagRelation? data =
      await dataBase.mediaTagRelationDao.queryRelationById(id);
  return data;
}


Future<void> updateRelation(MediaTagRelation relation) async {
  final FlutterDataBase dataBase = await FlutterDataBaseManager.database();
  await dataBase.mediaTagRelationDao.updateRelation(relation);
}

Future<int> searchRelationCount(SearchDTO searchDTO) async {
    final FlutterDataBase dataBase = await FlutterDataBaseManager.database();
    int count =
        await dataBase.mediaTagRelationDao.searchRelationCount(searchDTO.content ?? "") ?? 0;
    return count;
  }

  Future<List<MediaTagRelation>> searchRelationPage(SearchDTO searchDTO) async {
    final FlutterDataBase dataBase = await FlutterDataBaseManager.database();
    int pageSize = searchDTO.pageSize??20;
    int page = searchDTO.page??1;
    int offset = (page - 1) * pageSize;
    List<MediaTagRelation> list = await dataBase.mediaTagRelationDao.searchRelationPage(searchDTO.content??"",pageSize,offset);
    return list;
  }
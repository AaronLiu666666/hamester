import 'package:hamster/tag_manage/model/po/media_tag_relation.dart';

import '../config/db/flutter_data_base.dart';
import '../config/db/flutter_database_manager.dart';
import '../config/id_generator/id_generator.dart';
import 'model/dto/search_dto.dart';
import 'model/po/tag_info.dart';

class TagManageService {}

// 根据条件查询符合条件的媒体信息列表
Future<List<TagInfo>> getTagData(SearchDTO searchDto) async {
  final FlutterDataBase dataBase = await FlutterDataBaseManager.database();
  List<TagInfo> list =
  await dataBase.tagInfoDao.queryAllDataList();
  return list;
}

Future<TagInfo?> queryDataById(String id) async {
  final FlutterDataBase dataBase = await FlutterDataBaseManager.database();
  TagInfo? tagInfo =
      await dataBase.tagInfoDao.queryDataById(id);
  return tagInfo;
}

Future<void> updateData(TagInfo tagInfo) async {
  if (tagInfo == null) {
    return;
  }
  final FlutterDataBase dataBase = await FlutterDataBaseManager.database();
  await dataBase.tagInfoDao.updateData(tagInfo);
}

/// 创建标签-媒体关联数据 （如果同名标签不存在则先创建标签再创建关联关系）
Future<void> createMediaTagRelation(CreateMediaTagRelationDTO dto) async {
  final FlutterDataBase dataBase = await FlutterDataBaseManager.database();
  // 查询是否有重名标签，标签名为标签唯一标识，重名即认为是同一个标签
  List<TagInfo> tagInfos = await dataBase.tagInfoDao.queryTagsByTagName(dto.tagName);
  TagInfo tagInfo;
  int nowMilliseconds = DateTime.now().millisecondsSinceEpoch;
  if (tagInfos.isNotEmpty) {
    tagInfo = tagInfos[0];
  } else {
    tagInfo = TagInfo();
    tagInfo.id = UuidGenerator.generateUuid();
    tagInfo.tagName = dto.tagName;
    tagInfo.createTime = nowMilliseconds;
    tagInfo.updateTime = nowMilliseconds;
    await dataBase.tagInfoDao.insertOne(tagInfo);
  }
  MediaTagRelation mediaTagRelation = MediaTagRelation(
      id: UuidGenerator.generateUuid(),
      mediaId: dto.mediaId,
      tagId: tagInfo.id,
      mediaMoment: dto.mediaMoment,
      relationDesc: dto.description,
      mediaMomentPic: dto.picPath,
      createTime: nowMilliseconds,
      updateTime: nowMilliseconds);
  // 插入标签-媒体关联信息
  await dataBase.mediaTagRelationDao.insertOne(mediaTagRelation);

}

class CreateMediaTagRelationDTO {
  int mediaId;
  String tagName;
  String? mediaPath;
  String? description;
  String? picPath;
  int? mediaMoment;

  CreateMediaTagRelationDTO({
    required this.mediaId,
    required this.tagName,
    this.mediaPath,
    this.description,
    this.picPath,
    this.mediaMoment,
  });
}

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
  List<TagInfo> list = await dataBase.tagInfoDao.queryAllDataList();
  return list;
}

Future<TagInfo?> queryDataById(String id) async {
  final FlutterDataBase dataBase = await FlutterDataBaseManager.database();
  TagInfo? tagInfo = await dataBase.tagInfoDao.queryDataById(id);
  return tagInfo;
}

Future<List<TagInfo>> queryTagsByMediaId(int mediaId) async {
  final FlutterDataBase dataBase = await FlutterDataBaseManager.database();
  List<TagInfo> tagInfos = await dataBase.tagInfoDao.queryTagsByMediaId(mediaId);
  return tagInfos;
}

Future<void> updateData(TagInfo tagInfo) async {
  if (tagInfo == null) {
    return;
  }
  final FlutterDataBase dataBase = await FlutterDataBaseManager.database();
  await dataBase.tagInfoDao.updateData(tagInfo);
}

Future<List<TagInfo>> queryTagsByTagName(String tagName) async {
  final FlutterDataBase dataBase = await FlutterDataBaseManager.database();
  // 查询是否有重名标签，标签名为标签唯一标识，重名即认为是同一个标签
  List<TagInfo> tagInfos =
      await dataBase.tagInfoDao.queryTagsByTagName(tagName);
  return tagInfos;
}

/// 创建标签-媒体关联数据 （如果同名标签不存在则先创建标签再创建关联关系）
Future<void> createMediaTagRelation(CreateMediaTagRelationDTO dto) async {
  final FlutterDataBase dataBase = await FlutterDataBaseManager.database();
  // 查询是否有重名标签，标签名为标签唯一标识，重名即认为是同一个标签
  List<TagInfo> tagInfos =
      await dataBase.tagInfoDao.queryTagsByTagName(dto.tagName);
  TagInfo tagInfo;
  int nowMilliseconds = DateTime.now().millisecondsSinceEpoch;
  if (tagInfos.isNotEmpty) {
    tagInfo = tagInfos[0];
    String? tagPicConcat = tagInfo.tagPic;
    // 如果标签没有图片，选择第一次建立关联的关联时刻图作为tag的图片和封面
    if (null == tagPicConcat || tagPicConcat.isEmpty) {
      tagPicConcat = dto.picPath;
      // 更新tag
      tagInfo.tagPic = tagPicConcat;
      dataBase.tagInfoDao.updateData(tagInfo);
    }
  } else {
    tagInfo = TagInfo();
    tagInfo.id = UuidGenerator.generateUuid();
    tagInfo.tagName = dto.tagName;
    tagInfo.createTime = nowMilliseconds;
    tagInfo.updateTime = nowMilliseconds;
    tagInfo.tagPic = dto.picPath;
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

Future<void> insertOrUpdateTagInfo(String tagName,String? tagDesc,List<String> picList) async{
  final FlutterDataBase dataBase = await FlutterDataBaseManager.database();
  // 查询是否有重名标签，标签名为标签唯一标识，重名即认为是同一个标签
  List<TagInfo> tagInfos =
      await dataBase.tagInfoDao.queryTagsByTagName(tagName);
  TagInfo tagInfo;
  int nowMilliseconds = DateTime.now().millisecondsSinceEpoch;
  if (tagInfos.isNotEmpty) {
    tagInfo = tagInfos[0];
    tagInfo.updateTime = nowMilliseconds;
    tagInfo.tagName = tagName;
    tagInfo.tagDesc = tagDesc;
    tagInfo.tagPic = picList.join(",");
    dataBase.tagInfoDao.updateData(tagInfo);
  } else {
    tagInfo = TagInfo();
    tagInfo.id = UuidGenerator.generateUuid();
    tagInfo.tagName = tagName;
    tagInfo.tagDesc= tagDesc;
    tagInfo.tagPic = picList.join(",");
    tagInfo.createTime = nowMilliseconds;
    tagInfo.updateTime = nowMilliseconds;
    await dataBase.tagInfoDao.insertOne(tagInfo);
  }
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

Future<int> searchTagCount(SearchDTO searchDTO) async {
  final FlutterDataBase dataBase = await FlutterDataBaseManager.database();
  int count =
      await dataBase.tagInfoDao.searchTagCount(searchDTO.content ?? "") ?? 0;
  return count;
}

Future<List<TagInfo>> searchTagInfoPage(SearchDTO searchDTO) async {
  final FlutterDataBase dataBase = await FlutterDataBaseManager.database();
  int pageSize = searchDTO.pageSize??20;
  int page = searchDTO.page??1;
  int offset = (page - 1) * pageSize;
  List<TagInfo> list = await dataBase.tagInfoDao.searchTagInfoPage(searchDTO.content??"",pageSize,offset);
  return list;
}

Future<List<TagInfo>> searchTagInfoListByTagName(String tagName) async {
  final FlutterDataBase dataBase = await FlutterDataBaseManager.database();
  if(null==tagName||tagName.isEmpty){
    return List.empty();
  }
  List<TagInfo> list = await dataBase.tagInfoDao.searchTagInfoListByTagName(tagName);
  return list;
}

Future<void> deleteTagAndRelation(String tagId) async {
  final FlutterDataBase dataBase = await FlutterDataBaseManager.database();
  TagInfo? tagInfo = await dataBase.tagInfoDao.queryDataById(tagId);
  if(null == tagInfo){
    print("标签信息不存在");
    return;
  }
  // 删除标签
  await dataBase.tagInfoDao.deleteTagById(tagId);
  // 删除关联关系
  await dataBase.mediaTagRelationDao.deleteRelationByTagId(tagId);
}
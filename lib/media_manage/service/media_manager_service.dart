import 'dart:io';

import 'package:hamster/config/db/flutter_database_manager.dart';
import 'package:hamster/file/file_util.dart';
import 'package:hamster/media_manage/model/po/media_file_data.dart';
import 'package:hamster/tag_manage/model/po/tag_info.dart';

import '../../app_config_manage/service/app_config_service.dart';
import '../../config/db/flutter_data_base.dart';
import '../../config/id_generator/id_generator.dart';
import '../../customWidget/mainPage.dart';
import '../../file/file_finder_enhanced.dart';
import '../../permission/permission_util.dart';
import '../../tag_manage/model/dto/search_dto.dart';

class MediaManageService {
  Future<void> initMediaFileData() async {
    print("开始初始化媒体数据");
    // 创建数据表 判断是否存在数据表 由floor框架自动完成
    // 遍历文件目录寻找视频文件
    await requestPermissionDefault();

    // 修改存储图片的路径为应用内部存储目录下的子目录
    String picStorePath = await getPicStorePath();
    // 检查目录是否存在，如果不存在则创建目录
    Directory picStoreDir = Directory(picStorePath);
    if (!await picStoreDir.exists()) {
      picStoreDir.createSync(recursive: true);
    }
    Directory firstDirectory = Directory(picStorePath+"first/");
    if (!await firstDirectory.exists()) {
      firstDirectory.createSync(recursive: true);
    }
    Directory momentDirectory = Directory(picStorePath+"moment/");
    if (!await momentDirectory.exists()) {
      momentDirectory.createSync(recursive: true);
    }
    // String mediaSearchDirStr = ConfigManager.getString("media_search_dir");
    // List<String> searchPaths = EnvironmentConfig.searchPaths;
    List<String> searchPaths = await getMediaSearchConfigList();
    if(null == searchPaths || searchPaths.isEmpty) {
      print("扫描路径列表为空");
      return;
    }
    // 遍历searchPaths列表
    List<File> mediaFileList = List.empty(growable: true);
    for (String path in searchPaths) {
      Directory pathDir = Directory(path);
      if(!pathDir.existsSync()){
        continue;
      }
      List<File> files = await findFilesAsync(pathDir);
      if (files.isNotEmpty) {
        mediaFileList.addAll(files);
      }
    }
    if(null==mediaFileList||mediaFileList.isEmpty) {
      print("媒体扫描结果为空");
      return;
    }
    final FlutterDataBase dataBase = await FlutterDataBaseManager.database();
    List<MediaFileData> allMediaInDb =
        await dataBase.mediaFileDataDao.queryAllMediaFileDataList();
    // 过滤掉数据库中路径为空的媒体文件数据，并将路径转换为 Set
    Set<String> allMediaFilePathInDbSet = allMediaInDb
        .where(
            (mediaData) => mediaData.path != null && mediaData.path!.isNotEmpty)
        .map((mediaData) => mediaData.path!)
        .toSet();
    List<File> mediaFilteredList = mediaFileList.where((mediaData) {
      return !allMediaFilePathInDbSet.contains(mediaData.path);
    }).toList();

    for (var video in mediaFilteredList) {
      // String picFilename = UuidGenerator.generateUuid() + ".jpg";
      // String picPath = "$picStorePath/$picFilename";
      // getFirstFrame(video.path, picPath);
      MediaFileData mediaFileData = MediaFileData(
          id: null,
          path: video.path,
          fileName: getFileDisplayName(video),
          fileAlias: null,
          // calculateMD5(video),
          // md5 计算可以搞个类似于定时任务的，后台进行计算
          fileMd5: null,
          memo: null,
          // cover: picPath,
          cover: null,
          sourceUrl: null,
          lastPlayMoment: 0,
          lastPlayTime: 0,
          playNum: 0,
          createTime: DateTime.now().millisecondsSinceEpoch,
          updateTime: DateTime.now().millisecondsSinceEpoch);
      await dataBase.mediaFileDataDao.insertMember(mediaFileData);
    }
    print("媒体文件扫描结束");
  }

  // 根据条件查询符合条件的媒体信息列表
  Future<List<MediaFileData>> getMediaData(SearchDTO searchDto) async {
    final FlutterDataBase dataBase = await FlutterDataBaseManager.database();
    List<MediaFileData> list =
        await dataBase.mediaFileDataDao.queryAllMediaFileDataList();
    return list;
  }

  Future<List<CardContentData>> getMediaData2CardContentData(
      SearchDTO searchDto) async {
    List<MediaFileData> mediaFileDataList = await getMediaData(searchDto);
    List<CardContentData> cardContentDataList =
        mediaFileDataList.map((mediaFileData) {
      return CardContentData(
        id: mediaFileData.id ?? 0,
        path: mediaFileData.path ?? "",
        fileName: mediaFileData.fileName ?? "",
        url: mediaFileData.cover ?? "",
        text: mediaFileData.fileName,
      );
    }).toList();
    return cardContentDataList;
  }
}

Future<List<CardContentData>> getMediaData2CardContentData(
    SearchDTO searchDto) async {
  List<MediaFileData> mediaFileDataList = await getMediaData(searchDto);
  List<CardContentData> cardContentDataList =
      mediaFileDataList.map((mediaFileData) {
    return CardContentData(
      id: mediaFileData.id ?? 0,
      path: mediaFileData.path ?? "",
      fileName: mediaFileData.fileName ?? "",
      url: mediaFileData.cover ?? "",
      text: mediaFileData.fileName,
    );
  }).toList();
  return cardContentDataList;
}

// 根据条件查询符合条件的媒体信息列表
Future<List<MediaFileData>> getMediaData(SearchDTO searchDto) async {
  final FlutterDataBase dataBase = await FlutterDataBaseManager.database();
  List<MediaFileData> list =
      await dataBase.mediaFileDataDao.queryAllMediaFileDataList();
  return list;
}

Future<List<MediaFileData>> queryDatasByIds(List<int> ids) async {
  final FlutterDataBase dataBase = await FlutterDataBaseManager.database();
  List<MediaFileData> mediaDataList =
      await dataBase.mediaFileDataDao.queryDatasByIds(ids);
  return mediaDataList;
}

Future<MediaFileData?> queryMediaDataById(int id) async {
  final FlutterDataBase dataBase = await FlutterDataBaseManager.database();
  MediaFileData? data = await dataBase.mediaFileDataDao.queryMediaDataById(id);
  return data;
}

// 根据搜索条件搜索视频媒体列表
Future<List<CardContentData>> searchMediaDataBySearchDTO(
    SearchDTO searchDTO) async {
  List<MediaFileData> mediaFileDataList = List.empty();
  // 如果查询条件为空或者为null，则返回全部数据
  if (searchDTO.content == null || searchDTO.content!.isEmpty) {
    mediaFileDataList = await getMediaData(searchDTO);
  } else {
    final FlutterDataBase dataBase = await FlutterDataBaseManager.database();
    mediaFileDataList =
        await dataBase.mediaFileDataDao.searchMedia(searchDTO.content!);
  }
  List<CardContentData> cardContentDataList =
      mediaFileDataList.map((mediaFileData) {
    return CardContentData(
      id: mediaFileData.id ?? 0,
      path: mediaFileData.path ?? "",
      fileName: mediaFileData.fileName ?? "",
      url: mediaFileData.cover ?? "",
      text: mediaFileData.fileName,
    );
  }).toList();
  return cardContentDataList;
}

Future<List<MediaFileData>> searchMediaPage(SearchDTO searchDTO) async {
  final FlutterDataBase dataBase = await FlutterDataBaseManager.database();
  int pageSize = searchDTO.pageSize??20;
  int page = searchDTO.page??1;
  int offset = (page - 1) * pageSize;
  List<MediaFileData> list = await dataBase.mediaFileDataDao.searchMediaPage(searchDTO.content??"",pageSize,offset);
  return list;
}

Future<int> searchMediaCount(SearchDTO searchDTO) async {
  final FlutterDataBase dataBase = await FlutterDataBaseManager.database();
  int count = await dataBase.mediaFileDataDao.searchMediaCount(searchDTO.content??"")??0;
  return count;
}

Future<void> updateMediaFileData(MediaFileData mediaFileData) async {
  final FlutterDataBase dataBase = await FlutterDataBaseManager.database();
  await dataBase.mediaFileDataDao.updateData(mediaFileData);
}
import 'dart:io';

import 'package:hamster/config/db/flutter_database_manager.dart';
import 'package:hamster/file/file_util.dart';
import 'package:hamster/media_manage/model/po/media_file_data.dart';

import '../../config/config_manage/config_manage.dart';
import '../../config/db/flutter_data_base.dart';
import '../../config/id_generator/id_generator.dart';
import '../../customWidget/mainPage.dart';
import '../../file/file_finder_enhanced.dart';
import '../../media_process/video_process.dart';
import '../../permission/permission_util.dart';
import '../../tag_manage/model/dto/search_dto.dart';

class MediaManageService {
  Future<void> initMediaFileData() async {
    // 创建数据表 判断是否存在数据表 由floor框架自动完成
    // 遍历文件目录寻找视频文件
    await requestPermissionDefault();

    String mediaSearchDirStr = ConfigManager.getString("media_search_dir");
    Directory directory = Directory(mediaSearchDirStr);
    List<File> mediaFileList = await findFilesAsync(directory);
    if (mediaFileList.isNotEmpty) {
      print("视频文件：");
      mediaFileList.forEach((file) => print(file.path));
    } else {
      print("未找到视频文件。");
    }
    String picStoreDir = ConfigManager.getString('pic_store_dir');
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
      String picFilename = UuidGenerator.generateUuid() + ".jpg";
      String picPath = "$picStoreDir/$picFilename";
      getFirstFrame(video.path, picPath);
      MediaFileData mediaFileData = MediaFileData(
          null,
          video.path,
          getFileDisplayName(video),
          null,
          calculateMD5(video),
          null,
          picFilename,
          null,
          0,
          0,
          0,
          DateTime.now().millisecondsSinceEpoch,
          DateTime.now().millisecondsSinceEpoch);
      await dataBase.mediaFileDataDao.insertMember(mediaFileData);
    }
    List<MediaFileData> list =
        await dataBase.mediaFileDataDao.queryAllMediaFileDataList();
    print("媒体文件扫描结束");
  }

  // 根据条件查询符合条件的媒体信息列表
  Future<List<MediaFileData>> getMediaData(SearchDTO searchDto) async {
    final FlutterDataBase dataBase = await FlutterDataBaseManager.database();
    List<MediaFileData> list =
        await dataBase.mediaFileDataDao.queryAllMediaFileDataList();
    list.add(list[0]);
    list.add(list[0]);
    list.add(list[0]);
    list.add(list[0]);
    list.add(list[0]);
    list.add(list[0]);
    list.add(list[0]);
    list.add(list[0]);
    list.add(list[0]);
    list.add(list[0]);
    list.add(list[0]);
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
        url:
            "${ConfigManager.getString("pic_store_dir")}/${mediaFileData.cover}",
        text: mediaFileData.fileName,
      );
    }).toList();
    return cardContentDataList;
  }
}

Future<List<MediaFileData>> queryDatasByIds(List<int> ids) async {
  final FlutterDataBase dataBase = await FlutterDataBaseManager.database();
  List<MediaFileData> mediaDataList =
      await dataBase.mediaFileDataDao.queryDatasByIds(ids);
  return mediaDataList;
}

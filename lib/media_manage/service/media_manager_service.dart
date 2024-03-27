import 'dart:io';
import 'package:flutter_config/flutter_config.dart';
import 'package:hamster/config/db/flutter_database_manager.dart';
import 'package:hamster/file/file_finder.dart';
import 'package:hamster/db/db_init.dart';
import 'package:hamster/media_manage/model/po/media_file_data.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:hamster/file/file_util.dart';

import '../../config/config_manage/config_manage.dart';
import '../../config/db/flutter_data_base.dart';
import '../../config/id_generator/id_generator.dart';
import '../../file/file_finder_enhanced.dart';
import '../../media_process/video_process.dart';
import '../../permission/permission_util.dart';

class MediaManageService {
  Future<void> initMediaFileData() async {
    // // 判断是否存在数据表
    // // 创建数据表
    // 遍历文件目录寻找视频文件
    // List<File> mediaFileList = await FileFinder.findVideoFiles();
    await requestPermissionDefault();

    Directory directory = Directory("/storage/emulated/0/Download");
    List<File> mediaFileList = await findFilesAsync(directory);
    if (mediaFileList.isNotEmpty) {
      print("视频文件：");
      mediaFileList.forEach((file) => print(file.path));
    } else {
      print("未找到视频文件。");
    }
    // // 数据库插入数据
    // // Database db = await openDatabase(
    // //   join(await getDatabasesPath(), 'data.db'),
    // //   version: 1,
    // //   onCreate: (db, version) async {
    // //     // 创建数据表
    // //     await DbInit.createTable(db);
    // //   },
    // // );
    // // 遍历文件列表，将每个文件的信息插入到数据库中
    // for (File file in mediaFileList) {
    //   DateTime now = DateTime.now();
    //   await db.insert(
    //     'media_file_data',  // 你的数据表名称
    //     {
    //       'path': file.path,
    //       'file_name': getFileDisplayName(file),
    //       'file_md5': calculateMD5(file),
    //       'create_time': now,
    //       'update_time': now,
    //     // 其他字段的键值对
    //     },
    //     conflictAlgorithm: ConflictAlgorithm.replace, // 或者选择其他冲突解决算法
    //   );
    // }

    //
    String picStoreDir = ConfigManager.getString('pic_store_dir');
    final FlutterDataBase dataBase = await FlutterDataBaseManager.database();
    List<MediaFileData> allMediaInDb = await dataBase.mediaFileDataDao.queryAllMediaFileDataList();
    // 过滤掉数据库中路径为空的媒体文件数据，并将路径转换为 Set
    Set<String> allMediaFilePathInDbSet = allMediaInDb
        .where((mediaData) => mediaData.path != null && mediaData.path!.isNotEmpty)
        .map((mediaData) => mediaData.path!)
        .toSet();
    List<File> mediaFilteredList = mediaFileList.where((mediaData){
      return !allMediaFilePathInDbSet.contains(mediaData.path);
    }).toList();

    for(var video in mediaFilteredList){
      String picFilename = UuidGenerator.generateUuid()+".jpg";
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
}

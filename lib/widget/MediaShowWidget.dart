import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hamster/config/config_manage/config_manage.dart';
import 'package:hamster/media_manage/model/po/media_file_data.dart';

import '../config/db/flutter_data_base.dart';
import '../config/db/flutter_database_manager.dart';
import '../customWidget/mainPage.dart';

class MediaShowWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MediaFileData>>(
      // 异步获取数据
      future: _fetchMediaData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // 加载中的指示器
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('No data available');
        } else {
          // 数据加载完成，构建 UI
          List<CardContentData> cardContentDataList = snapshot.data!
              .map((mediaFileData) => CardContentData(
                    url: "${ConfigManager.getString("pic_store_dir")}/${mediaFileData.cover}.jpg",
                    text: mediaFileData.fileName,
                  ))
              .toList();
          return MainPageWidget(datas: cardContentDataList);
        }
      },
    );
  }

  Future<List<MediaFileData>> _fetchMediaData() async {
    final FlutterDataBase dataBase = await FlutterDataBaseManager.database();
    List<MediaFileData> list = await dataBase.mediaFileDataDao.queryAllMediaFileDataList();
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
}

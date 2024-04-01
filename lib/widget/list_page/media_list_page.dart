import 'package:flutter/cupertino.dart';
import 'package:hamster/media_manage/service/media_manager_service.dart';

import '../../customWidget/mainPage.dart';
import '../../tag_manage/model/dto/search_dto.dart';

/// 媒体文件列表页面
class MediaListPage extends StatefulWidget {
  @override
  _MediaListPageState createState() => _MediaListPageState();
}

class _MediaListPageState extends State<MediaListPage> {
  List<CardContentData> dataList = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      MediaManageService mediaManageService = MediaManageService();
      mediaManageService.initMediaFileData();
      List<CardContentData> cardContentDataList =
          await mediaManageService.getMediaData2CardContentData(SearchDTO());

      setState(() {
        dataList = cardContentDataList;
      });
    } catch (e) {
      // 处理异常
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    int crossAxisCount = 2; // 设置网格列数
    return GridView.count(
      crossAxisCount: crossAxisCount,
      children: dataList.map((data) => CardWidget(data: data)).toList(),
    );
  }
}

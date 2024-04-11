import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hamster/media_manage/service/media_manager_service.dart';
import 'package:provider/provider.dart';

import '../../customWidget/mainPage.dart';
import '../../providers/search_provider.dart';

/// 媒体文件列表页面
class MediaListPage extends StatefulWidget {
  @override
  _MediaListPageState createState() => _MediaListPageState();
}

class _MediaListPageState extends State<MediaListPage> {
  List<CardContentData> dataList = [];

  late MediaSearchProvider _mediaSearchProvider;

  @override
  void initState() {
    super.initState();
    _fetchData();
    // 监听MediaSearchProvider的变化
    _mediaSearchProvider =
        Provider.of<MediaSearchProvider>(context, listen: false);
    _mediaSearchProvider.addListener(_search);
  }

  @override
  void dispose() {
    // 在页面销毁时取消监听
    // 首先检查是否存在监听器
    if (_mediaSearchProvider != null) {
      // 如果存在，再移除监听器
      _mediaSearchProvider.removeListener(_search);
    }

    super.dispose();
  }

  Future<void> _fetchData() async {
    _search();
  }

  Future<void> _refreshData() async {
    MediaManageService mediaManageService = MediaManageService();
    mediaManageService.initMediaFileData();
  }

  @override
  Widget build(BuildContext context) {
    int crossAxisCount = 2; // 设置网格列数
    // todo 初始化和遍历文件逻辑目前不太好，比较耗时，现在暂时用下拉页面初始化数据的方式
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: GridView.count(
        crossAxisCount: crossAxisCount,
        children: dataList.map((data) => CardWidget(data: data)).toList(),
      ),
    );
  }

  Future<void> _search() async {
    try {
      // 获取 Provider
      final mediaSearchProvider =
          Provider.of<MediaSearchProvider>(context, listen: false);
      // 获取搜索条件
      final searchDTO = mediaSearchProvider.searchDTO;
      print("搜索条件：" + (searchDTO.content ?? ""));
      List<CardContentData> searchResult =
          await searchMediaDataBySearchDTO(searchDTO);
      setState(() {
        dataList = searchResult;
      });
    } catch (e) {
      // 处理错误
      print('获取数据时出错：$e');
    }
  }
}

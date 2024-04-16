import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:hamster/media_manage/model/po/media_file_data.dart';
import 'package:hamster/tag_manage/model/dto/search_dto.dart';
import 'package:hamster/widget/list_page/page_util/page_util.dart';
import 'package:provider/provider.dart';

import '../../customWidget/mainPage.dart';
import '../../file/thumbnail_util.dart';
import '../../media_manage/service/media_manager_service.dart';
import '../../providers/search_provider.dart';
import 'media_home_page.dart';

/// 媒体文件列表页面
class MediaPageListPage extends StatefulWidget {
  @override
  _MediaPageListPageState createState() => _MediaPageListPageState();
}

class _MediaPageListPageState extends State<MediaPageListPage> {
  late MediaSearchProvider _mediaSearchProvider;

  @override
  void initState() {
    super.initState();
    _mediaSearchProvider =
        Provider.of<MediaSearchProvider>(context, listen: false);
    _mediaSearchProvider.addListener(_search);
  }

  @override
  void dispose() {
    // 在页面销毁时取消监听
    _mediaSearchProvider.removeListener(_search);
    super.dispose();
  }

  void _search() {
    Get.find<MediaPagingController>().refreshDataNotScan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('媒体文件列表'),
      // ),
      body: GetBuilder<MediaPagingController>(
        init: MediaPagingController(),
        builder: (controller) {
          return buildRefreshListWidget<MediaFileData, MediaPagingController>(
            itemBuilder: (data, index) => CardWidget(
                data: CardContentData(
              id: data.id ?? 0,
              path: data.path ?? "",
              fileName: data.fileName ?? "",
              url: data.cover ?? "",
              text: data.fileName,
            )),
            enablePullDown: true,
            enablePullUp: true,
            physics: AlwaysScrollableScrollPhysics(),
            onItemClick: (data, index) {
              // 处理点击事件
            },
          );
        },
      ),
    );
  }
}

class MediaPagingController
    extends PagingController<MediaFileData, PagingState<MediaFileData>> {
  @override
  Future<PagingData<MediaFileData>?> loadData(PagingParams pagingParams) async {
    CustomSearchController searchController = Get.find<CustomSearchController>();
    // 刷新数据
    SearchDTO homepageSearchDTO = searchController.getSearchDTO();
    SearchDTO searchDTO =
        SearchDTO(page: pagingParams.current, pageSize: pagingParams.size);
    searchDTO.content = homepageSearchDTO.content;
    int total = await searchMediaCount(searchDTO);
    final List<MediaFileData> list = await searchMediaPage(searchDTO);
    // 为没有生成缩略图的视频添加缩略图
    generateMediaListThumbnailImages(list);
    int pages = (total / pagingParams.size).ceil();
    return PagingData<MediaFileData>()
      ..current = pagingParams.current
      ..pages = pages
      ..data = list
      ..size = pagingParams.size // 设置每页数据量
      ..total = total;
  }

  @override
  PagingState<MediaFileData> getState() {
    return PagingState<MediaFileData>()..refreshId = this;
  }

  @override
  Future<void> initBeforeLoadData() async {
    // 下拉刷新的时候调用的方法，下拉刷新时会重新扫描媒体文件列表
    MediaManageService mediaManageService= MediaManageService();
    await mediaManageService.initMediaFileData();
  }

}

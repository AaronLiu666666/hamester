import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hamster/widget/list_page/page_util/page_util.dart';

import '../../config/id_generator/id_generator.dart';
import '../../file/thumbnail_util.dart';
import '../../media_manage/model/po/media_file_data.dart';
import '../../media_manage/service/media_manager_service.dart';
import '../../tag_manage/model/dto/search_dto.dart';
import '../list_page/media_home_page.dart';
import '../list_page/media_page_list_page.dart';
import 'custom_material_controls.dart';

class VideoHorizontalScrollWidget extends StatelessWidget {
  // final VideoHorizontalScrollPagingController videoHorizontalScrollPagingController = Get.put(VideoHorizontalScrollPagingController());

  final void Function(int videoId, String videoPath)? onVideoSelected; // 声明回调函数

  VideoHorizontalScrollWidget({Key? key, this.onVideoSelected}) : super(key: key){
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<VideoHorizontalScrollPagingController>(
      builder: (controller) {
        return buildCustomRefreshListWidget<MediaFileData, VideoHorizontalScrollPagingController>(
          // tag: controller.tag,
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          listEnum: ListEnum.list,
          enablePullDown: true,
          enablePullUp: true,
          physics: AlwaysScrollableScrollPhysics(),
          onItemClick: (data, index) {
            // 检查是否定义了onVideoSelected回调函数，如果是，则调用它并传递视频ID和路径
            if (onVideoSelected != null) {
              onVideoSelected!(data.id??0, data.path??"");
            }
          },
          itemBuilder: (data, index) => Padding(
            padding: EdgeInsets.symmetric(horizontal: 2),
            child: Card(
              color: Colors.white.withOpacity(0.3),
              child: SizedBox(
                height: 70,
                width: 80,
                child: Image.file(
                  File(data.cover ?? ""),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  // final VideoHorizontalScrollPagingController controller = Get.find<VideoHorizontalScrollPagingController>();

  // @override
  // Widget build(BuildContext context) {
  //   return Obx(
  //         () => buildCustomRefreshListWidget<MediaFileData, VideoHorizontalScrollPagingController>(
  //       shrinkWrap: true,
  //       scrollDirection: Axis.horizontal,
  //       listEnum: ListEnum.list,
  //       enablePullDown: true,
  //       enablePullUp: true,
  //       physics: AlwaysScrollableScrollPhysics(),
  //       onItemClick: (data, index) {
  //         // 处理点击事件
  //       },
  //       itemBuilder: (data, index) => Padding(
  //         padding: EdgeInsets.symmetric(horizontal: 2),
  //         child: Card(
  //           color: Colors.white.withOpacity(0.3),
  //           child: SizedBox(
  //             height: 70,
  //             width: 80,
  //             child: Image.file(
  //               File(data.cover ?? ""),
  //               fit: BoxFit.cover,
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
}

class VideoHorizontalScrollPagingController
    extends PagingController<MediaFileData, PagingState<MediaFileData>> {

  // String tag = UuidGenerator.generateUuid();

  @override
  Future<PagingData<MediaFileData>?> loadData(PagingParams pagingParams) async {
    CustomSearchController searchController =
        Get.find<CustomSearchController>();
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
    MediaManageService mediaManageService = MediaManageService();
    await mediaManageService.initMediaFileData();
  }
}

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hamster/tag_manage/model/po/media_tag_relation.dart';
import 'package:hamster/tag_manage/tag_manage_service.dart';
import 'package:hamster/widget/list_page/getx_tag_detail_page.dart';
import 'package:hamster/widget/list_page/media_home_page.dart';
import 'package:hamster/widget/list_page/page_util/page_util.dart';
import 'package:hamster/widget/list_page/tag_detail_page.dart';

import '../../relation_manage/relation_manage_service.dart';
import '../../tag_manage/model/dto/search_dto.dart';
import '../../tag_manage/model/po/tag_info.dart';
import '../video_chewie/video_chewie_page.dart';

/// 标签列表页面
class TagPageListPage extends StatefulWidget {
  @override
  _TagPageListPageState createState() => _TagPageListPageState();
}

class _TagPageListPageState extends State<TagPageListPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TagPagingController>(
      init: TagPagingController(),
      builder: (controller) {
        return buildRefreshListWidget<TagInfo, TagPagingController>(
            itemBuilder: (data, index) => GestureDetector(
                  onTap: () async {
                    List<MediaTagRelation> relationList = await queryRelationsByTagIdWithMediaPath(data.id!);
                    if (null!=relationList && relationList.isNotEmpty){
                      MediaTagRelation firstRelation = relationList[0];
                      Get.to(
                            () => VideoChewiePage(
                          videoId: firstRelation.mediaId!,
                          videoPath: firstRelation.mediaPath!,
                          seekTo: firstRelation.mediaMoment,
                          videoPageFromType: VideoPageFromType.tag_page,
                              tagId: data.id,
                        ),
                        binding: BindingsBuilder(() {
                          Get.put(VideoChewiePageController());
                        }),
                      );
                    }
                  },
                  onLongPress: () {
                    Get.to(() => GetxTagDetailPage(), arguments: data.id!,
                        binding: BindingsBuilder(() {
                      Get.put(GetxTagDetailController());
                    }));
                  },
                  child: Card(
                    margin: EdgeInsets.all(10),
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: _buildImageWidget(data.tagPic),
                        ),
                        Tooltip(
                          message: data.tagName ?? "", // 提示框中显示完整的文本内容
                          child: Text(
                            data.tagName ?? "",
                            // 最多展示1行，超过省略展示，防止文字过多展示时占用了图片的空间，导致图片显示过小或者展示不出来问题
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center, // 文字居中显示
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            enablePullDown: true,
            enablePullUp: true,
            physics: AlwaysScrollableScrollPhysics(),
            onItemClick: (data, index) {});
      },
    );
  }

  Widget _buildImageWidget(String? imagePath) {
    if (imagePath != null && imagePath.isNotEmpty) {
      List<String> imagePaths = imagePath.split(',');
      // 如果路径不为空，则加载文件中的图片
      return Image.file(File(imagePaths[0]), fit: BoxFit.cover);
    } else {
      // 否则加载默认的空图片
      return Image.asset('assets/image/no-pictures.png');
    }
  }
}

class TagPagingController
    extends PagingController<TagInfo, PagingState<TagInfo>> {
  @override
  PagingState<TagInfo> getState() {
    return PagingState<TagInfo>()..refreshId = this;
  }

  @override
  Future<void> initBeforeLoadData() async {}

  @override
  Future<PagingData<TagInfo>?> loadData(PagingParams pagingParams) async {
    CustomSearchController searchController =
        Get.find<CustomSearchController>();
    SearchDTO homepageSearchDTO = searchController.getSearchDTO();
    SearchDTO searchDTO = SearchDTO(
      page: pagingParams.current,
      pageSize: pagingParams.size,
      content: homepageSearchDTO.content,
    );
    int total = await searchTagCount(searchDTO);
    final List<TagInfo> list = await searchTagInfoPage(searchDTO);
    int pages = (total / pagingParams.size).ceil();
    return PagingData<TagInfo>()
      ..current = pagingParams.current
      ..pages = pages
      ..data = list
      ..size = pagingParams.size // 设置每页数据量
      ..total = total;
  }
}

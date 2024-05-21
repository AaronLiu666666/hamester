import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:hamster/tag_manage/model/po/media_tag_relation.dart';
import 'package:hamster/widget/list_page/page_util/page_util.dart';
import 'package:hamster/widget/video_chewie/video_chewie_page.dart';

import '../../relation_manage/relation_manage_service.dart';
import '../detail_page/relation_detial_page.dart';

class VideoRelationHorizontalScrollWidget extends StatelessWidget {
  VideoRelationHorizontalScrollWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<VideoRelationHorizontalScrollPagingController>(
      builder: (controller) {
        return buildCustomRefreshListWidget<MediaTagRelation,
            VideoRelationHorizontalScrollPagingController>(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          listEnum: ListEnum.list,
          enablePullDown: true,
          enablePullUp: true,
          physics: AlwaysScrollableScrollPhysics(),
          onItemClick: (data, index) {
            Get.find<VideoChewiePageController>().seekTo(data.mediaMoment ?? 0);
          },
          onItemLongPress: (data,index) {
            Get.find<VideoChewiePageController>().pause();
              Get.to(() => GetxRelationDetailPage(),
                  binding: BindingsBuilder(() {
                    Get.put(GetxRelationDetailPageController(id:data.id??""));
                  }))?.then((value) => Get.find<VideoChewiePageController>().play());
          },
          itemBuilder: (data, index) => Padding(
            padding: EdgeInsets.symmetric(horizontal: 2),
            child: Card(
              color: Colors.white.withOpacity(0.3),
              child: SizedBox(
                height: 70,
                width: 80,
                child: Image.file(
                  File(data.mediaMomentPic ?? ""),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class VideoRelationHorizontalScrollPagingController
    extends PagingController<MediaTagRelation, PagingState<MediaTagRelation>> {
  RxInt videoId;

  VideoRelationHorizontalScrollPagingController({required this.videoId});

  @override
  Future<PagingData<MediaTagRelation>?> loadData(
      PagingParams pagingParams) async {
    List<MediaTagRelation> relationList = await queryRelationsByMediaId(videoId.value);
    relationList = relationList.where((relation) => relation.mediaMoment != null).toList();
  // 创建一个 Map 来保存每个 mediaMoment 的第一个记录
    final Map<int, MediaTagRelation> filteredMap = {};

    for (var relation in relationList) {
      // 过滤掉mediaMoment为null的
      if(relation.mediaMoment == null){
        continue;
      }
      // 过滤掉相同时刻的精彩时刻，只保留一条
      if (!filteredMap.containsKey(relation.mediaMoment)) {
        filteredMap[relation.mediaMoment!] = relation;
      }
    }

    // 将 Map 转换回 List
    relationList = filteredMap.values.toList();
    // 按 mediaMoment 正序排序
    relationList.sort((a, b) => a.mediaMoment!.compareTo(b.mediaMoment!));
    return PagingData<MediaTagRelation>()
      ..current = 1
      ..pages = 1
      ..data = relationList
      ..size = relationList.length // 设置每页数据量
      ..total = relationList.length;
  }

  @override
  PagingState<MediaTagRelation> getState() {
    return PagingState<MediaTagRelation>()..refreshId = this;
  }

  @override
  Future<void> initBeforeLoadData() async {}
}

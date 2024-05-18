import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:hamster/tag_manage/model/po/media_tag_relation.dart';
import 'package:hamster/widget/list_page/page_util/page_util.dart';
import 'package:hamster/widget/video_chewie/video_chewie_page.dart';

import '../../relation_manage/relation_manage_service.dart';

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

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hamster/tag_manage/model/po/tag_info.dart';

import '../../relation_manage/relation_manage_service.dart';
import '../../tag_manage/model/po/media_tag_relation.dart';
import '../../tag_manage/tag_manage_service.dart';
import '../custom_widget/card_flying_widget.dart';
import '../detail_page/tag_detail_page.dart';
import '../video_chewie/video_chewie_page.dart';

class TagCardFlyingController extends CardFlyingController<TagInfo> {
  @override
  Future<List<TagInfo>> loadData() async {
    List<TagInfo> allMedias = await queryAllTagData();
    return allMedias;
  }
}

class TagCardFlyingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TagCardFlyingController cardFlyingController =
        Get.put(TagCardFlyingController());
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(cardFlyingController.isAnimating
                ? Icons.pause
                : Icons.play_arrow),
            onPressed: () {
              cardFlyingController.toggleAnimation();
            },
          ),
        ],
      ),
      body: GetBuilder<TagCardFlyingController>(
        builder: (controller) {
          return buildCardFlyingWidget<TagInfo, TagCardFlyingController>(
              itemBuilder: (data, index) {
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0), // 设置圆角
              ),
              // elevation: 5, // 设置阴影
              // color: Colors.blue[(index % 9 + 1) * 100],
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0), // 设置图片圆角
                child: _buildImageWidget(data.tagPic),
              ),
            );
          }, onItemClick: (data, index) async {
            List<MediaTagRelation> relationList =
                await queryRelationsByTagIdWithMediaPath(data.id!);
            if (null != relationList && relationList.isNotEmpty) {
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
                  Get.put(VideoChewiePageController(
                    videoId: firstRelation.mediaId!,
                    videoPath: firstRelation.mediaPath!,
                    seekTo: firstRelation.mediaMoment,
                    videoPageFromType: VideoPageFromType.tag_page,
                    tagId: data.id,
                  ));
                }),
              )?.then((value) {
                controller.toggleAnimation();
              });
            }
          }, onItemLongPress: (data, index) {
            Get.to(() => GetxTagDetailPage(), arguments: data.id!,
                binding: BindingsBuilder(() {
              Get.put(GetxTagDetailController());
            }))?.then((value) {
              controller.toggleAnimation();
            });
          });
        },
      ),
    );
  }
}

Widget _buildImageWidget(String? imagePath) {
  if (imagePath != null && imagePath.isNotEmpty) {
    List<String> imagePaths = imagePath.split(',');
    File imageFile = File(imagePaths[0]);
    // 如果路径不为空，则加载文件中的图片
    return SizedBox(
      width: 160,
      height: 120,
      child: Image.file(imageFile, fit: BoxFit.cover),
    );
  } else {
    // 否则加载默认的空图片
    return Image.asset('assets/image/no-pictures.png');
  }
}

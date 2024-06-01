import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../relation_manage/relation_manage_service.dart';
import '../../tag_manage/model/po/media_tag_relation.dart';
import '../custom_widget/card_flying_widget.dart';
import '../detail_page/relation_detial_page.dart';
import '../detail_page/tag_detail_page.dart';
import '../video_chewie/video_chewie_page.dart';

class RelationCardFlyingController
    extends CardFlyingController<MediaTagRelation> {
  @override
  Future<List<MediaTagRelation>> loadData() async {
    List<MediaTagRelation> allRelations = await getAllRelationInfo();
    return allRelations;
  }
}

class RelationCardFlyingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final RelationCardFlyingController cardFlyingController =
        Get.put(RelationCardFlyingController());
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
      body: GetBuilder<RelationCardFlyingController>(
        builder: (controller) {
          return buildCardFlyingWidget<MediaTagRelation,
              RelationCardFlyingController>(itemBuilder: (data, index) {
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0), // 设置圆角
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0), // 设置图片圆角
                child: _buildImageWidget(data.mediaMomentPic),
              ),
            );
          }, onItemClick: (data, index) async {
            Get.to(
              () => VideoChewiePage(
                videoId: data.mediaId!,
                videoPath: data.mediaPath!,
                seekTo: data.mediaMoment,
                videoPageFromType: VideoPageFromType.relation_page,
              ),
              binding: BindingsBuilder(() {
                Get.put(VideoChewiePageController(
                  videoId: data.mediaId!,
                  videoPath: data.mediaPath!,
                  seekTo: data.mediaMoment,
                  videoPageFromType: VideoPageFromType.relation_page,
                ));
              }),
            );
          }, onItemLongPress: (data, index) {
            Get.to(() => GetxRelationDetailPage(), binding: BindingsBuilder(() {
              Get.put(GetxRelationDetailPageController(id: data.id ?? ""));
            }));
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
    // int imageWidth;
    // int imageHeight;
    // Image imageNetwork = Image(image: FileImage(imageFile));
    // imageNetwork.image.resolve(ImageConfiguration()).addListener(
    //   ImageStreamListener(
    //     (ImageInfo info, bool _) {
    //       imageWidth = info.image.width;
    //       imageHeight = info.image.height;
    //     },
    //   ),
    // );
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

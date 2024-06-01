import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hamster/media_manage/model/po/media_file_data.dart';

import '../../media_manage/service/media_manager_service.dart';
import '../custom_widget/card_flying_widget.dart';
import '../detail_page/media_detail_page.dart';
import '../video_chewie/video_chewie_page.dart';

class MediaCardFlyingController
    extends CardFlyingController<MediaFileData> {
  @override
  Future<List<MediaFileData>> loadData() async {
    List<MediaFileData> allMedias = await queryAllMedias();
    return allMedias;
  }
}

class MediaCardFlyingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final MediaCardFlyingController cardFlyingController =
    Get.put(MediaCardFlyingController());
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
      body: GetBuilder<MediaCardFlyingController>(
        builder: (controller) {
          return buildCardFlyingWidget<MediaFileData,
              MediaCardFlyingController>(
              itemBuilder: (data, index) {
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0), // 设置圆角
                  ),
                  // elevation: 5, // 设置阴影
                  // color: Colors.blue[(index % 9 + 1) * 100],
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.0), // 设置图片圆角
                    child: _buildImageWidget(data.cover),
                  ),
                );
              },
              onItemClick: (data, index) {
                Get.to(
                      () =>
                      VideoChewiePage(
                        videoId: data.id!,
                        videoPath: data.path!,
                        videoPageFromType: VideoPageFromType.media_page,
                      ),
                  binding: BindingsBuilder(() {
                    Get.put(VideoChewiePageController(
                      videoId: data.id!,
                      videoPath: data.path!,
                      videoPageFromType: VideoPageFromType.media_page,
                    ));
                  }),
                );
              },
              onItemLongPress: (data, index) {
                Get.to(() => MediaDetailPage(),
                    binding: BindingsBuilder(() {
                      Get.put(MediaDetailPageController(mediaId:data.id!));
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

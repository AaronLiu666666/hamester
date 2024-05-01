import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hamster/widget/video_chewie/video_horizontal_scroll_widget.dart';
import 'package:video_player/video_player.dart';

import 'custom_material_controls.dart';

class VideoChewiePageController extends GetxController {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  late VideoHorizontalScrollPagingController
      _videoHorizontalScrollPagingController;

  final RxInt _videoId = 0.obs;
  final RxString _videoPath = ''.obs;
  final RxInt _seekTo = 0.obs;
  late VideoPageFromType _videoPageFromType;

  void setVideoInfo(
      {required int videoId,
      required String videoPath,
      int? seekTo,
      VideoPageFromType videoPageFromType = VideoPageFromType.media_page}) {
    _videoId.value = videoId;
    _videoPath.value = videoPath;
    _seekTo.value = seekTo ?? 0;
    _videoPageFromType = videoPageFromType;
  }

  VideoPageFromType getVideoPageFromType() {
    return _videoPageFromType;
  }

  Future<Widget> buildVideoWidget() async {
    try {
      await initialize();
      return Chewie(
        controller: _chewieController,
      );
    } catch (e) {
      print("Error building video widget: $e");
      return Container(); // Return an empty container if initialization fails
    }
  }

  Future<void> initialize() async {
    print("Initializing VideoPlayerController for $_videoPath");
    _videoPlayerController = VideoPlayerController.file(File(_videoPath.value));

    await _videoPlayerController.initialize();
    print("VideoPlayerController initialized successfully.");

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
      showControls: true,
      customControls: CustomMaterialControls(
          videoId: _videoId.value, seekTo: _seekTo.value),
      aspectRatio: _videoPlayerController.value.aspectRatio,
    );

    _videoHorizontalScrollPagingController =
        Get.put(VideoHorizontalScrollPagingController());
  }

  @override
  void onClose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    _videoHorizontalScrollPagingController.dispose();
    Get.delete<VideoHorizontalScrollPagingController>();
    super.onClose();
  }

  @override
  void dispose() {
    // Get.delete<VideoChewiePageController>();
    super.dispose();
  }

  void switchVideo(
      {required int videoId, required String videoPath, int? seekTo}) async {
    _videoId.value = videoId;
    _videoPath.value = videoPath;
    _seekTo.value = seekTo ?? 0;
    await _videoPlayerController.pause();
    await _videoPlayerController.dispose();
    _chewieController.dispose();
    update();
  }
}

// class VideoChewiePage extends GetView<VideoChewiePageController> {
class VideoChewiePage extends StatelessWidget {
  final int videoId;
  final String videoPath;
  final int? seekTo;
  final VideoPageFromType videoPageFromType;

  VideoChewiePage({
    required this.videoId,
    required this.videoPath,
    this.seekTo,
    this.videoPageFromType = VideoPageFromType.media_page,
  });

  @override
  Widget build(BuildContext context) {
    VideoChewiePageController controller =
        Get.find<VideoChewiePageController>();
    controller.setVideoInfo(
      videoId: videoId,
      videoPath: videoPath,
      seekTo: seekTo,
      videoPageFromType: videoPageFromType,
    );
    return GetBuilder<VideoChewiePageController>(builder: (controller) {
      return FutureBuilder<Widget>(
        future: controller.buildVideoWidget(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            return snapshot.data ?? Container();
          }
        },
      );
    });
  }
}

enum VideoPageFromType {
  media_page,
  tag_detail_relation_list,
  tag_detail_video_list
}

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

  late int _videoId;
  late String _videoPath;
  late int? _seekTo;
  late VideoPageFromType _videoPageFromType;

  void setVideoInfo(
      {required int videoId,
      required String videoPath,
      int? seekTo,
      VideoPageFromType videoPageFromType = VideoPageFromType.media_page}) {
    _videoId = videoId;
    _videoPath = videoPath;
    _seekTo = seekTo;
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
    _videoPlayerController = VideoPlayerController.file(File(_videoPath));

    await _videoPlayerController.initialize();
    print("VideoPlayerController initialized successfully.");

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
      showControls: true,
      customControls:
          CustomMaterialControls(videoId: _videoId, seekTo: _seekTo),
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
    _videoId = videoId;
    _videoPath = videoPath;
    _seekTo = seekTo;
    await _videoPlayerController.pause();
    await _videoPlayerController.dispose();
    _chewieController.dispose();
    // 更新界面状态,直接就会重新初始化了
    print("Initializing VideoPlayerController for $_videoPath");
    _videoPlayerController = VideoPlayerController.file(File(_videoPath));

    await _videoPlayerController.initialize();
    print("VideoPlayerController initialized successfully.");

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
      showControls: true,
      customControls:
      CustomMaterialControls(videoId: _videoId, seekTo: _seekTo),
      aspectRatio: _videoPlayerController.value.aspectRatio,
    );

    update();
  }
}

class VideoChewiePage extends GetView<VideoChewiePageController> {
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
    controller.setVideoInfo(
      videoId: videoId,
      videoPath: videoPath,
      seekTo: seekTo,
      videoPageFromType: videoPageFromType,
    );
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
  }
}


enum VideoPageFromType {
  media_page,
  tag_detail_relation_list,
  tag_detail_video_list
}

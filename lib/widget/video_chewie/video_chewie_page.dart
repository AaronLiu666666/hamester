import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
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
  late String? _tagId;
  RxBool isIniting = true.obs;
  late CustomMaterialControls customMaterialControls;

   late VideoHorizontalScrollWidget videoHorizontalScrollWidget =
   VideoHorizontalScrollWidget(key: ValueKey<String>("sdfdsf"));

  VideoChewiePageController(
      {required int videoId,
      required String videoPath,
      int? seekTo,
      VideoPageFromType videoPageFromType = VideoPageFromType.media_page,
      String? tagId}) {
    _videoId.value = videoId;
    _videoPath.value = videoPath;
    _seekTo.value = seekTo ?? 0;
    _videoPageFromType = videoPageFromType;
    _tagId = tagId;
  }

  String getTagId() {
    return _tagId ?? "";
  }

  ChewieController getChewieController() {
    return _chewieController;
  }

  VideoPlayerController getVideoPlayerController() {
    return _videoPlayerController;
  }

  @override
  void onInit() {
    super.onInit();
    _videoHorizontalScrollPagingController =
        Get.put(VideoHorizontalScrollPagingController());
    // videoHorizontalScrollWidget = VideoHorizontalScrollWidget(key: const ValueKey<String>("dfjalsdkf"),);
    initialize();
  }

  // void setVideoInfo(
  //     {required int videoId,
  //     required String videoPath,
  //     int? seekTo,
  //     VideoPageFromType videoPageFromType = VideoPageFromType.media_page,
  //     String? tagId}) {
  //   _videoId.value = videoId;
  //   _videoPath.value = videoPath;
  //   _seekTo.value = seekTo ?? 0;
  //   _videoPageFromType = videoPageFromType;
  //   _tagId = tagId;
  // }

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
    try {
      print("Initializing VideoPlayerController for $_videoPath");
      _videoPlayerController =
          VideoPlayerController.file(File(_videoPath.value));

      await _videoPlayerController.initialize();
      print("VideoPlayerController initialized successfully.");

      customMaterialControls = CustomMaterialControls(
          videoHorizontalScrollWidget: videoHorizontalScrollWidget,
          videoId: _videoId.value,
          seekTo: _seekTo.value);

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        looping: false,
        showControls: true,
        customControls: customMaterialControls,
        aspectRatio: _videoPlayerController.value.aspectRatio,
      );
      // _videoHorizontalScrollPagingController =
      //     Get.put(VideoHorizontalScrollPagingController());
    } finally {
      isIniting.value = false;
    }
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
    _videoPlayerController.dispose();
    _chewieController.dispose();
    _videoHorizontalScrollPagingController.dispose();
    Get.delete<VideoHorizontalScrollPagingController>();
    super.dispose();
  }

  // void switchVideo(
  //     {required int videoId, required String videoPath, int? seekTo}) async {
  //   _videoId.value = videoId;
  //   _videoPath.value = videoPath;
  //   _seekTo.value = seekTo ?? 0;
  //   await _videoPlayerController.pause();
  //   await _videoPlayerController.dispose();
  //   _chewieController.dispose();
  //
  //   // update();
  // }
  // }

  // Future<void> toggleVideo() async {
  //   await _videoPlayerController.pause();
  //   List<VideoDTO> videoDTOList = _videoHorizontalScrollPagingController.pagingState.data;
  //   _videoHorizontalScrollPagingController.loadMoreData()
  //   currPlayIndex.value += 1;
  //   if (currPlayIndex >= playList.length) {
  //     currPlayIndex.value = 0;
  //   }
  //   await _initializePlayer();
  // }

  void switchVideo(
      {required int videoId, required String videoPath, int? seekTo}) async {
    isIniting.value = true;
    _videoId.value = videoId;
    _videoPath.value = videoPath;
    _seekTo.value = seekTo ?? 0;

    // 停止视频播放
    await _videoPlayerController.pause();

    // 释放已经存在的 VideoPlayerController
    await _videoPlayerController.dispose();
    // 初始化新的视频控制器
    _videoPlayerController = VideoPlayerController.file(File(_videoPath.value));
    await _videoPlayerController.initialize();

    // 初始化 Chewie 控制器
    ChewieController newChewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
      showControls: true,
      autoInitialize: true,
      // customControls:
      // CustomMaterialControls(
      //     videoHorizontalScrollWidget:
      //         VideoChewiePageController.videoHorizontalScrollWidget,
      //     videoId: _videoId.value,
      //     seekTo: _seekTo.value),
      customControls: customMaterialControls,
      aspectRatio: _videoPlayerController.value.aspectRatio,
    );
    _chewieController.dispose();
    _chewieController = newChewieController;
    isIniting.value = false;
    // 不再调用 update() 方法
  }
}

// class VideoChewiePage extends GetView<VideoChewiePageController> {
class VideoChewiePage extends GetView<VideoChewiePageController> {
  final int videoId;
  final String videoPath;
  final int? seekTo;
  final VideoPageFromType videoPageFromType;
  final String? tagId;

  VideoChewiePage(
      {required this.videoId,
      required this.videoPath,
      this.seekTo,
      this.videoPageFromType = VideoPageFromType.media_page,
      this.tagId});

  @override
  Widget build(BuildContext context) {
    VideoChewiePageController controller =
        Get.find<VideoChewiePageController>();
    // controller.setVideoInfo(
    //   videoId: videoId,
    //   videoPath: videoPath,
    //   seekTo: seekTo,
    //   videoPageFromType: videoPageFromType,
    //   tagId: tagId,
    // );
    // return GetBuilder<VideoChewiePageController>(builder: (controller) {
    // return FutureBuilder<Widget>(
    //   future: controller.buildVideoWidget(),
    //   builder: (context, snapshot) {
    //     if (snapshot.connectionState == ConnectionState.waiting) {
    //       return Center(child: CircularProgressIndicator());
    //     } else {
    //       return snapshot.data ?? Container();
    //     }
    //   },
    // );
    // });
    // return Obx(
    //   () => controller.isIniting.value
    //       ? const Center(child: CircularProgressIndicator())
    //       : Chewie(
    //           key: ValueKey<String>("sdfdsfs"),
    //           controller: controller.getChewieController(),
    //         ),
    // );
    // return Scaffold(
    //     body: SafeArea(
    //         child: Stack(children: [
    //   Positioned(
    //     top: 0,
    //     left: 0,
    //     right: 0,
    //     child: Container(
    //         color: Colors.black,
    //         height: MediaQuery.of(context).size.width / (controller.getVideoPlayerController().value.aspectRatio),
    //         child: Obx(() {
    //           return controller.isIniting.value == false
    //               ? Chewie(
    //                   controller: controller.getChewieController(),
    //                 )
    //               : const Column(
    //                   mainAxisAlignment: MainAxisAlignment.center,
    //                   children: [
    //                     CircularProgressIndicator(),
    //                   ],
    //                 );
    //         })),
    //   ),
    // ])));
   return Scaffold(
     backgroundColor: Colors.black,
        body: SafeArea(
            child: Stack(children: [
      Positioned(
        top: 100,
        left: 0,
        right: 0,
        child: Container(
            color: Colors.black,
            height: MediaQuery.of(context).size.width * 9 / 16,
            child: Obx(() {
              return controller.isIniting.value == false
                  ? Chewie(
                      controller: controller.getChewieController(),
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                      ],
                    );
            })),
      ),
              Positioned(bottom: 0,left: 0,right: 0,
                  child:
                  Container(
                    height: 100,
                    padding: EdgeInsets.all(2),
                    width: double.maxFinite,
                    // child: VideoHorizontalScrollWidget(),
                    // 将相同的 ValueKey 传递给 VideoHorizontalScrollWidget
                    // child: VideoHorizontalScrollWidget(
                    //   key: const ValueKey<String>('video_horizontal_scroll_key'),
                    // ),
                    child: controller.videoHorizontalScrollWidget,
                  ),
              )
    ])));
  }
}

enum VideoPageFromType {
  media_page,
  tag_detail_relation_list,
  tag_detail_video_list,
  // 关联库页面
  relation_page,
  // 标签库页面
  tag_page,
  // 视频详情页面
  media_detail_page,
  // 关联详情页面
  relation_detial_page,
}

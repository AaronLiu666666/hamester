import 'dart:async';
import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:chewie/src/chewie_player.dart';
import 'package:chewie/src/notifiers/index.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hamster/widget/video_chewie/video_horizontal_scroll_widget.dart';
import 'package:provider/provider.dart';
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

  // late PlayerNotifier notifier;
  late RxBool playerHideStuff = false.obs;

  late RxBool videoHorizontalScrollWidgetHideStuff = false.obs;

  Timer? videoHorizontalScrollWidgetHideStuffTimer;

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

  void setHideStuffValue(bool value) {
    playerHideStuff.value = value;
    if (value == false) {
      videoHorizontalScrollWidgetHideStuff.value = value;
      // 在内部播放器状态设置为显示时，重置底下滑动列表的计时器
      resetVideoHorizontalScrollWidgetHideStuffTimer();
    }
  }

  void resetVideoHorizontalScrollWidgetHideStuffTimer() {
    // 取消旧的计时器（如果存在）
    videoHorizontalScrollWidgetHideStuffTimer?.cancel();
    // 创建并启动新的计时器
    videoHorizontalScrollWidgetHideStuffTimer =
        Timer.periodic(const Duration(milliseconds: 3000), (timer) {
      videoHorizontalScrollWidgetHideStuff.value = true;
    });
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
        // videoHorizontalScrollWidget: videoHorizontalScrollWidget,
        videoId: _videoId.value,
        seekTo: _seekTo.value,
        function: setHideStuffValue,
      );

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        looping: false,
        showControls: true,
        customControls: customMaterialControls,
        aspectRatio: _videoPlayerController.value.aspectRatio,
      );

      videoHorizontalScrollWidgetHideStuffTimer =
          Timer.periodic(const Duration(milliseconds: 3000), (timer) {
        videoHorizontalScrollWidgetHideStuff.value = true;
      });
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
    videoHorizontalScrollWidgetHideStuffTimer?.cancel();
    super.dispose();
  }

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
      customControls: CustomMaterialControls(
        videoId: _videoId.value,
        seekTo: _seekTo.value,
        function: setHideStuffValue,
      ),
      aspectRatio: _videoPlayerController.value.aspectRatio,
    );
    _chewieController.dispose();
    _chewieController = newChewieController;
    isIniting.value = false;
  }
}

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
    // https://github.com/fluttercommunity/chewie/issues/742 查找chewie issues 将横向滚动切换条放到父组件中
    // return Scaffold(
    //     backgroundColor: Colors.black,
    //     body: SafeArea(
    //         child: Stack(children: [
    //       Center(
    //         child: Container(
    //           height: MediaQuery.of(context).size.width * 9 / 16,
    //           child: Obx(() {
    //             return controller.isIniting.value == false
    //                 ? Chewie(
    //                     controller: controller.getChewieController(),
    //                   )
    //                 : Center(child: CircularProgressIndicator());
    //           }),
    //         ),
    //       ),
    //       Positioned(
    //         bottom: 0,
    //         left: 0,
    //         right: 0,
    //         child: Obx(() {
    //           // 在不显示的时候吸收点击事件，否则就算隐藏了，还是能够进行点击
    //           // 但是这样还是有个问题，下面拖动框正拖动着呢，拖着拖着自己隐藏了。。。
    //           return AbsorbPointer(
    //             absorbing:
    //                 controller.videoHorizontalScrollWidgetHideStuff.value,
    //             // child: AnimatedOpacity(
    //             //   opacity: controller.videoHorizontalScrollWidgetHideStuff.value ? 0 : 1,
    //             //   duration: const Duration(milliseconds: 300),
    //             //   child: Container(
    //             //     height: 100,
    //             //     padding: EdgeInsets.all(2),
    //             //     width: double.maxFinite,
    //             //     child: controller.videoHorizontalScrollWidget,
    //             //   ),
    //             // ),
    //             child: GestureDetector(
    //               behavior: HitTestBehavior.opaque,
    //               onTap: () {
    //                 // Handle tap event
    //                 controller.resetVideoHorizontalScrollWidgetHideStuffTimer();
    //                 controller.videoHorizontalScrollWidgetHideStuff.value =
    //                     false;
    //               },
    //               onVerticalDragStart: (details) {
    //                 // Handle vertical drag start event
    //                 controller.resetVideoHorizontalScrollWidgetHideStuffTimer();
    //                 controller.videoHorizontalScrollWidgetHideStuff.value =
    //                     false;
    //               },
    //               onVerticalDragUpdate: (details) {
    //                 // Handle vertical drag update event
    //                 controller.resetVideoHorizontalScrollWidgetHideStuffTimer();
    //                 controller.videoHorizontalScrollWidgetHideStuff.value =
    //                     false;
    //               },
    //               onHorizontalDragStart: (details) {
    //                 /**
    //                     https://juejin.cn/post/6844903954959056904?from=search-suggest
    //                     横向滑动的组件会把滚动事件给拦截，父组件监听不动子组件的滚动，也就没有办法重置videoHorizontalScrollWidgetHideStuff
    //
    //                  */
    //                 // Handle horizontal drag start event
    //                 controller.resetVideoHorizontalScrollWidgetHideStuffTimer();
    //                 controller.videoHorizontalScrollWidgetHideStuff.value =
    //                     false;
    //               },
    //               onHorizontalDragUpdate: (details) {
    //                 // Handle horizontal drag update event
    //                 controller.resetVideoHorizontalScrollWidgetHideStuffTimer();
    //                 controller.videoHorizontalScrollWidgetHideStuff.value =
    //                     false;
    //               },
    //               child: AnimatedOpacity(
    //                 opacity:
    //                     controller.videoHorizontalScrollWidgetHideStuff.value
    //                         ? 0
    //                         : 1,
    //                 duration: const Duration(milliseconds: 300),
    //                 child: Container(
    //                   height: 100,
    //                   padding: EdgeInsets.all(2),
    //                   width: double.maxFinite,
    //                   child: controller.videoHorizontalScrollWidget,
    //                 ),
    //               ),
    //             ),
    //           );
    //         }),
    //       ),
    //     ])));
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Container(
                height: MediaQuery.of(context).size.width * 9 / 16,
                child: Obx(() {
                  return controller.isIniting.value == false
                      ? Chewie(
                          controller: controller.getChewieController(),
                        )
                      : Center(child: CircularProgressIndicator());
                }),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  // Handle scroll notification here
                  if (notification is ScrollUpdateNotification) {
                    // Handle scroll update
                    controller.resetVideoHorizontalScrollWidgetHideStuffTimer();
                    controller.videoHorizontalScrollWidgetHideStuff.value =
                        false;
                  }
                  return false;
                },
                child: Obx(
                  () => AbsorbPointer(
                    absorbing:
                        controller.videoHorizontalScrollWidgetHideStuff.value,
                    child: AnimatedOpacity(
                      opacity:
                          controller.videoHorizontalScrollWidgetHideStuff.value
                              ? 0
                              : 1,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        height: 100,
                        padding: EdgeInsets.all(2),
                        width: double.maxFinite,
                        child: controller.videoHorizontalScrollWidget,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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

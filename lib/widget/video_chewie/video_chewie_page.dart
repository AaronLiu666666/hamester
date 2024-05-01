import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hamster/widget/video_chewie/video_horizontal_scroll_widget.dart';
import 'package:video_player/video_player.dart';

import 'custom_material_controls.dart';


// class VideoChewiePage extends StatelessWidget {
//   final int videoId;
//   final String videoPath;
//   final int? seekTo;
//
//   VideoChewiePage({required this.videoId, required this.videoPath, this.seekTo});
//
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<VideoChewiePageController>(
//       init: VideoChewiePageController(),
//       builder: (controller) {
//         return FutureBuilder<Widget>(
//           future: controller.buildVideoWidget(videoPath, videoId, seekTo),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return Center(child: CircularProgressIndicator());
//             } else {
//               return snapshot.data ?? Container();
//             }
//           },
//         );
//       },
//     );
//   }
// }
//
// class VideoChewiePageController extends GetxController {
//   late VideoPlayerController _videoPlayerController;
//   late ChewieController _chewieController;
//   late VideoHorizontalScrollPagingController _videoHorizontalScrollPagingController;
//
//   late int _videoId;
//   late String _videoPath;
//   late int? _seekTo;
//
//   void setVideoInfo({required int videoId, required String videoPath, int? seekTo}) {
//     _videoId = videoId;
//     _videoPath = videoPath;
//     _seekTo = seekTo;
//   }
//
//   Future<Widget> buildVideoWidget(String videoPath, int videoId, int? seekTo) async {
//     try {
//       await initialize(videoPath: videoPath, videoId: videoId, seekTo: seekTo);
//       return Chewie(
//         controller: _chewieController,
//       );
//     } catch (e) {
//       print("Error building video widget: $e");
//       return Container(); // Return an empty container if initialization fails
//     }
//   }
//
//   Future<void> initialize({required String videoPath, required int videoId, int? seekTo}) async {
//     print("Initializing VideoPlayerController for $videoPath");
//     _videoPlayerController = VideoPlayerController.file(File(videoPath));
//
//     await _videoPlayerController.initialize();
//     print("VideoPlayerController initialized successfully.");
//
//     _chewieController = ChewieController(
//       videoPlayerController: _videoPlayerController,
//       autoPlay: true,
//       looping: false,
//       showControls: true,
//       customControls: CustomMaterialControls(videoId: videoId, seekTo: seekTo),
//       aspectRatio: _videoPlayerController.value.aspectRatio,
//     );
//
//     _videoHorizontalScrollPagingController = Get.put(VideoHorizontalScrollPagingController());
//     // 如果加了这个update 会导致死循环initialize
//     // update();
//   }
//
//   @override
//   void onClose() {
//     _videoPlayerController.dispose();
//     _chewieController.dispose();
//     _videoHorizontalScrollPagingController.dispose();
//     Get.delete<VideoHorizontalScrollPagingController>();
//     super.onClose();
//   }
//
//   void switchVideo({required int videoId, required String videoPath, int? seekTo}) async {
//     await _videoPlayerController.pause();
//     await _videoPlayerController.dispose();
//     _chewieController.dispose();
//     // 更新界面状态
//     update();
//     print("Initializing VideoPlayerController for $videoPath");
//     _videoPlayerController = VideoPlayerController.file(File(videoPath));
//
//     await _videoPlayerController.initialize();
//     print("VideoPlayerController initialized successfully.");
//
//     _chewieController = ChewieController(
//       videoPlayerController: _videoPlayerController,
//       autoPlay: true,
//       looping: false,
//       showControls: true,
//       customControls: CustomMaterialControls(videoId: videoId,seekTo: seekTo),
//       aspectRatio: _videoPlayerController.value.aspectRatio,
//     );
//     // update();
//   }
// }

class VideoChewiePageController extends GetxController {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  late VideoHorizontalScrollPagingController _videoHorizontalScrollPagingController;

  late int _videoId;
  late String _videoPath;
  late int? _seekTo;

  void setVideoInfo({required int videoId, required String videoPath, int? seekTo}) {
    _videoId = videoId;
    _videoPath = videoPath;
    _seekTo = seekTo;
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
      customControls: CustomMaterialControls(videoId: _videoId, seekTo: _seekTo),
      aspectRatio: _videoPlayerController.value.aspectRatio,
    );

    _videoHorizontalScrollPagingController = Get.put(VideoHorizontalScrollPagingController());
    // 如果加了这个update 会导致死循环initialize
    // update();
  }

  @override
  void onClose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    _videoHorizontalScrollPagingController.dispose();
    Get.delete<VideoHorizontalScrollPagingController>();
    super.onClose();
  }

  void switchVideo({required int videoId, required String videoPath, int? seekTo}) async {
    _videoId = videoId;
    _videoPath = videoPath;
    _seekTo = seekTo;
    await _videoPlayerController.pause();
    await _videoPlayerController.dispose();
    _chewieController.dispose();
    // 更新界面状态,直接就会重新初始化了
    update();
  }
}

class VideoChewiePage extends StatelessWidget {
  final int videoId;
  final String videoPath;
  final int? seekTo;

  VideoChewiePage({required this.videoId, required this.videoPath, this.seekTo});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VideoChewiePageController());
    controller.setVideoInfo(videoId: videoId, videoPath: videoPath, seekTo: seekTo);

    return GetBuilder<VideoChewiePageController>(
      builder: (controller) {
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
      },
    );
  }
}


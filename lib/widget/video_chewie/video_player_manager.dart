import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerManager extends ChangeNotifier {
  late VideoPlayerController _controller;
  int _videoId = 0;

  VideoPlayerManager(String videoPath, int videoId) {
    _controller = VideoPlayerController.file(File(videoPath));
    _videoId = videoId;
    _controller.initialize().then((_) {
      notifyListeners(); // 初始化完成后通知监听器
    });
  }

  VideoPlayerController get controller => _controller;

  int get videoId => _videoId;

  // 切换视频的方法
  void switchVideo(String videoPath, int videoId) {
    _controller.dispose();
    _controller = VideoPlayerController.file(File(videoPath));
    _videoId = videoId;
    _controller.initialize().then((_) {
      notifyListeners(); // 切换视频完成后通知监听器
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'custom_material_controls.dart';

class VideoChewiePage extends StatefulWidget {

  final int videoId;

  final String videoPath;

  final int? seekTo;

  VideoChewiePage({required this.videoId,required this.videoPath,this.seekTo});

  @override
  _VideoChewiePageState createState() => _VideoChewiePageState();
}

class _VideoChewiePageState extends State<VideoChewiePage> {
  late VideoPlayerController _videoPlayerController;

  late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.file(File(widget.videoPath));

    // 等待_videoPlayerController初始化完成
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      // aspectRatio: _videoPlayerController.value.aspectRatio,
      // aspectRatio: 16 / 9,
      autoPlay: true,
      looping: false,
      showControls: true,
      customControls: CustomMaterialControls(videoId: widget.videoId,seekTo: widget.seekTo,),
    );
    //该监听器会在_videoPlayerController的状态发生变化时被调用
    _videoPlayerController.addListener(() {
      // 检查视频尺寸信息是否可用
      // 计算视频宽高比
      double aspectRatio = _videoPlayerController.value.aspectRatio;
      // 比较aspectRatio，不一样才setState
      // 更新ChewieController的aspectRatio属性
      // 必须不等的时候才setState 要不会影响计时自动消失的
      if(_chewieController.aspectRatio!=aspectRatio){
        setState(() {
          _chewieController =
              _chewieController.copyWith(aspectRatio: aspectRatio);
        });
      }
    });
  }

  // void initializeControllers() async {
  //   _videoPlayerController = VideoPlayerController.file(File(widget.videoPath));
  //
  //   // 等待_videoPlayerController初始化完成
  //   await _videoPlayerController.initialize();
  //
  //   // 初始化_chewieController
  //   _chewieController = ChewieController(
  //     videoPlayerController: _videoPlayerController,
  //     aspectRatio: _videoPlayerController.value.aspectRatio,
  //     // aspectRatio: 16 / 9,
  //     autoPlay: true,
  //     looping: false,
  //     showControls: true,
  //     // customControls: Column(
  //     //   children: [
  //     //
  //     //   ],
  //     // ),
  //   );
  // }


  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Chewie(
      controller: _chewieController,
    );
    //   Stack(children: <Widget>[
    //   Chewie(
    //     controller: _chewieController,
    //   ),
    //   CameraIcon(),
    // ]);
  }
}

class ChewieCustomControl extends StatefulWidget {
  @override
  _ChewieCustomControlState createState() => _ChewieCustomControlState();
}

class _ChewieCustomControlState extends State<ChewieCustomControl> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

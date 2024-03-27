/// Created by RongCheng on 2022/1/20.

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hamster/widget/video/video_player_bottom.dart';
import 'package:hamster/widget/video/video_player_center.dart';
import 'package:hamster/widget/video/video_player_gestures.dart';
import 'package:hamster/widget/video/video_player_top.dart';

import '../../other/temp_value.dart';
import '../../utils/video_player_utils.dart';

class VideoPlayerPage extends StatefulWidget {

  final String videoUrl;

  const VideoPlayerPage({Key? key, required this.videoUrl}) : super(key: key);
  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  // 是否全屏
  bool get _isFullScreen => MediaQuery.of(context).orientation == Orientation.landscape;
  Size get _window => MediaQueryData.fromWindow(window).size;
  double get _width => _isFullScreen ? _window.width : _window.width;
  double get _height => _isFullScreen ? _window.height : _window.width*9/16;
  Widget? _playerUI;
  VideoPlayerTop? _top;
  VideoPlayerBottom? _bottom;
  LockIcon? _lockIcon; // 控制是否沉浸式的widget
  CameraIcon? _cameraIcon;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    VideoPlayerUtils.playerHandle(widget.videoUrl, autoPlay: true);
    VideoPlayerUtils.initializedListener(key: this, listener: (initialize,widget){
      if(initialize){
        _top ??= VideoPlayerTop();
        _lockIcon ??= LockIcon(lockCallback: (){
          _top!.opacityCallback(!TempValue.isLocked);
          _bottom!.opacityCallback(!TempValue.isLocked);
        },);
        // liurong todo 初始化截图 _cameraIcon
        _cameraIcon ??= CameraIcon();
        _bottom ??= VideoPlayerBottom();
        // liurong question —_playerUI 是该widget自己？ _playerUI 在这里指代的是当前 VideoPlayerPage 对象本身，或者说是 VideoPlayerPage 类的一个实例。
        _playerUI = widget;
        if(!mounted) return;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    VideoPlayerUtils.removeInitializedListener(this);
    VideoPlayerUtils.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isFullScreen ? null : AppBar(title: const Text("视频示例"),),
      body: _isFullScreen ? safeAreaPlayerUI() : Column(
        children: [
          safeAreaPlayerUI(),
          // const SizedBox(height: 100,),
          // InkWell(
          //   // 切换视频
          //   onTap: () => _changeVideo(),
          //   child: Container(
          //     alignment: Alignment.center,
          //     width: 120, height: 60,
          //     color: Colors.orangeAccent,
          //     child: const Text("切换视频",style: TextStyle(fontSize: 18),),
          //   ),
          // )
        ],
      )
    );
  }

  Widget safeAreaPlayerUI(){
    return SafeArea( // 全屏的安全区域
      top: !_isFullScreen,
      bottom: !_isFullScreen,
      left: !_isFullScreen,
      right: !_isFullScreen,
      child: SizedBox(
        height: _height,
        width: _width,
        child: _playerUI != null ? VideoPlayerGestures(
          appearCallback: (appear){
            _top!.opacityCallback(appear);
            _lockIcon!.opacityCallback(appear);
            _bottom!.opacityCallback(appear);
            },
          children: [
            Center(
              child: _playerUI,
            ),
            _top!,
            _lockIcon!,
            _cameraIcon!,
            _bottom!
          ],
        ) : Container(
          alignment: Alignment.center,
          color: Colors.black26,
          child: const CircularProgressIndicator(
            strokeWidth: 3,
          ),
        )
      ),
    );
  }


  void _changeVideo(){
    _playerUI = null;
    setState(() {});
    VideoPlayerUtils.playerHandle(_urls[_index]);
    _index += 1;
    if(_index == _urls.length){
      _index = 0;
    }
  }
  // void _changeVideoUrl(String url) {
  //   _playerUI = null;
  //   setState(() {});
  //   _currentVideoUrl = url;
  //   VideoPlayerUtils.playerHandle(_currentVideoUrl);
  // }

  void _changeVideoUrl(String url){
    _playerUI = null;
    setState(() {});
    VideoPlayerUtils.playerHandle(url);
  }

  final List<String> _urls = [
    "/storage/emulated/0/Download/D3.mp4",
  ];
  int _index = 1;
}

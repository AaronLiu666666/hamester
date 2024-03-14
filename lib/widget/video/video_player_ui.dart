// 简单使用
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../utils/video_player_utils.dart';

class VideoPlayerUI extends StatefulWidget {

  // 在 Flutter 的元素树中，每个 Widget 都需要一个唯一的标识符。如果没有提供 Key，Flutter 将会自动生成一个默认的标识符。
  const VideoPlayerUI({Key? key}) : super(key: key);

  @override
  _VideoPlayerUIState createState() => _VideoPlayerUIState();
}

class _VideoPlayerUIState extends State<VideoPlayerUI> {
  Widget? _playerUI;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // 播放视频
    VideoPlayerUtils.playerHandle("/storage/emulated/0/Download/D3.mp4");
    // 播放新视频，初始化监听
    VideoPlayerUtils.initializedListener(key: this, listener: (initialize,widget){
      if(initialize){
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
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        width: 414,
        height: 414*9/16,
        color: Colors.black26,
        child: _playerUI ?? const CircularProgressIndicator(
          strokeWidth: 3,
        )
    );
  }
}

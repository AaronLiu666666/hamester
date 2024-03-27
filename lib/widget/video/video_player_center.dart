/// Created by RongCheng on 2022/1/20.

import 'package:flutter/material.dart';

import '../../other/temp_value.dart';
import '../../utils/video_player_utils.dart';

/// center 右中部 实时截图按钮
class CameraIcon extends StatefulWidget {
  @override
  _CameraIconState createState() => _CameraIconState();
}

class _CameraIconState extends State<CameraIcon> {
  // 透明度
  double _opacity = 1.0;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(milliseconds: 250),
      child: Align(
        alignment: Alignment.centerRight,
        child: IconButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            // liurong todo 点击进行截图
            VideoPlayerUtils.captureCurrentFrame();
          },
          icon: Icon(Icons.camera_outlined,color:Colors.white,size:25,)
        ),
      ),
    );
  }

  @override
  void initState() {}
}

// ignore: must_be_immutable
class LockIcon extends StatefulWidget {
  LockIcon({Key? key, required this.lockCallback}) : super(key: key);
  final Function lockCallback;
  late Function(bool) opacityCallback;

  @override
  _LockIconState createState() => _LockIconState();
}

class _LockIconState extends State<LockIcon> {
  double _opacity = 1.0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.opacityCallback = (appear) {
      if (TempValue.isLocked) return; // 如果当前isLocked，不会触发，防止快速点击误触
      _opacity = appear ? 1.0 : 0.0;
      if (!mounted) return;
      setState(() {});
    };
  }

  @override
  Widget build(BuildContext context) {
    ///  AnimatedOpacity，它是一个带有动画效果的组件，用于控制子组件的透明度。这里通过 opacity 属性来控制透明度的变化，duration 属性指定了透明度变化的动画持续时间。
    return AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(milliseconds: 250),
      child: Align(
        alignment: Alignment.centerLeft,
        child: IconButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            TempValue.isLocked = !TempValue.isLocked;
            widget.lockCallback();
            if (!mounted) return;
            setState(() {});
          },
          icon: Icon(
            TempValue.isLocked ? Icons.lock_outlined : Icons.lock_open_outlined,
            color: Colors.white,
            size: 25,
          ),
        ),
      ),
    );
  }
}

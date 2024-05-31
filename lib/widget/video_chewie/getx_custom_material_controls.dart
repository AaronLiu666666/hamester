import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:chewie/src/center_play_button.dart';
import 'package:chewie/src/chewie_player.dart';
import 'package:chewie/src/chewie_progress_colors.dart';
import 'package:chewie/src/helpers/utils.dart';
import 'package:chewie/src/material/material_progress_bar.dart';
import 'package:chewie/src/material/widgets/options_dialog.dart';
import 'package:chewie/src/material/widgets/playback_speed_dialog.dart';
import 'package:chewie/src/models/option_item.dart';
import 'package:chewie/src/models/subtitle_model.dart';
import 'package:chewie/src/notifiers/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hamster/widget/video_chewie/video_relation_horizontal_scroll_wdiget.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../config/id_generator/id_generator.dart';
import '../../file/file_finder_enhanced.dart';
import '../../file/thumbnail_util.dart';
import '../../media_manage/model/po/media_file_data.dart';
import '../../media_manage/service/media_manager_service.dart';
import '../tag/media_tag_add_widget.dart';

class GetxCustomMaterialControls extends StatelessWidget {
  final bool showPlayButton;
  final int videoId;
  final int? seekTo;
  final Function(bool hideStuff)? function;

  GetxCustomMaterialControls({
    this.showPlayButton = true,
    required this.videoId,
    this.seekTo,
    this.function,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MaterialControlsController>(
      init: MaterialControlsController(
        showPlayButton: showPlayButton,
        videoId: videoId,
        seekTo: seekTo,
        function: function,
        context: context, // 传递上下文
      ),
      builder: (controller) {
        if (controller.latestValue.hasError) {
          return Center(
              child: Icon(Icons.error, color: Colors.white, size: 42));
        }

        // return GestureDetector(
        //   onTap: controller.toggleControlsVisibility,
        //   child: Stack(
        //     children: [
        //       if (controller.displayBufferingIndicator)
        //         Center(child: CircularProgressIndicator()),
        //       if (controller.showPlayButton && !controller.controller.value.isPlaying)
        //         CenterPlayButton(
        //           backgroundColor: Colors.black54,
        //           iconColor: Colors.white,
        //           isFinished: controller.isFinished,
        //           isPlaying: controller.controller.value.isPlaying,
        //           show: showPlayButton,
        //           onPressed: controller.togglePlayPause,
        //         ),
        //       Align(
        //         alignment: Alignment.bottomCenter,
        //         child: MaterialControlsBar(
        //           controller: controller,
        //         ),
        //       ),
        //     ],
        //   ),
        // );
        return MouseRegion(
          onHover: (_) {
            controller.cancelAndRestartTimer();
          },
          child: GestureDetector(
            onTap: () => controller.cancelAndRestartTimer(),
            /*
        AbsorbPointer 是 Flutter 中的一个小部件，用于在其子树中吸收用户输入事件，从而阻止用户与其子树中的小部件进行交互。当 AbsorbPointer 的 absorbing 属性为 true 时，它会阻止其子树中的小部件接收指针事件。
        这个小部件通常用于在特定情况下禁用用户与某些小部件的交互，比如在显示某些信息时，禁止用户点击按钮或输入框等。
         */
            child: AbsorbPointer(
              absorbing: controller.notifier.hideStuff,
              //  Stack 小部件，它允许将子部件堆叠在一起。在这里，它被用于布局视频播放器控件的各个组成部分。
              child: Stack(
                children: [
                  // _displayBufferingIndicator 为 true，则显示一个圆形进度条，用于指示视频正在缓冲。
                  if (controller.displayBufferingIndicator)
                    const Center(
                      child: CircularProgressIndicator(),
                    )
                  else
                    //_buildHitArea()，即视频播放区域的命中区域
                    controller._buildHitArea(),

                  //这个部分构建了视频播放器的操作栏，用于显示一些操作按钮，比如字幕切换按钮等
                  controller._buildActionBar(),
                  // 这里是一个 Column，包含了视频播放器底部的内容。
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      controller._buildBottomBar(context),
                    ],
                  ),
                  // 添加实时截图按钮组件
                  // CameraIcon(),
                  controller._buildCameraButton(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class MaterialControlsController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final bool showPlayButton;
  final int videoId;
  final int? seekTo;
  final Function(bool hideStuff)? function;

  late VideoPlayerController controller;
  late VideoPlayerValue latestValue;
  double? latestVolume;
  Timer? hideTimer;
  Timer? initTimer;
  Duration subtitlesPosition = Duration.zero;
  bool subtitleOn = false;
  Timer? showAfterExpandCollapseTimer;
  bool dragging = false;
  bool displayTapped = false;
  Timer? bufferingDisplayTimer;
  bool displayBufferingIndicator = false;
  bool locked = false;
  ChewieController? chewieController;
  Timer? timer;
  var hideStuff = false.obs;
  bool isFinished = false;
  late PlayerNotifier notifier; // 保留 notifier

  final barHeight = 48.0 * 1.5;
  final marginSize = 5.0;
  BuildContext context;

  MaterialControlsController({
    required this.showPlayButton,
    required this.videoId,
    this.seekTo,
    this.function,
    required this.context,
  });

  @override
  void onInit() {
    super.onInit();
    notifier = Provider.of<PlayerNotifier>(context, listen: false);
    chewieController = ChewieController.of(context);
    controller = chewieController!.videoPlayerController;
    _initialize();
  }

  @override
  void didChangeDependencies(BuildContext context) {
    // 进入播放页面 点击播放页面全屏 都会调用
    final oldController = chewieController;
    notifier = Provider.of<PlayerNotifier>(context, listen: false);
    chewieController = ChewieController.of(context);
    controller = chewieController!.videoPlayerController;
    if (oldController != chewieController) {
      _dispose();
      _initialize();
    }
    super.didChangeDependencies(context);
  }

  void _dispose() {
    controller.removeListener(_updateState);
    hideTimer?.cancel();
    initTimer?.cancel();
    showAfterExpandCollapseTimer?.cancel();
    WakelockPlus.disable();
  }

  void _initialize() {
    if (controller.value.isPlaying || chewieController!.autoPlay) {
      hideTimer = Timer(const Duration(seconds: 3), () {
        hideStuff.value = true;
      });
    }
    initTimer = Timer(const Duration(milliseconds: 200), () {
      WakelockPlus.enable();
      if (seekTo != null) {
        seekToPosition(seekTo!);
      }
    });
    _updateState();
  }

  void _updateState() {
    latestValue = controller.value;
    isFinished = latestValue.position >= latestValue.duration;
    if (latestValue.isBuffering) {
      _startBufferingIndicator();
    } else {
      _stopBufferingIndicator();
    }
  }

  void cancelAndRestartTimer() {
    hideTimer?.cancel();
    _startHideTimer();
    notifier.hideStuff = false;
    // if (null != context.function) {
    //   widget.function!(false);
    // }
    displayTapped = true;
    update();
    // setState(() {
    // });
  }

  void _startBufferingIndicator() {
    bufferingDisplayTimer?.cancel();
    bufferingDisplayTimer = Timer(const Duration(milliseconds: 100), () {
      displayBufferingIndicator = true;
      update();
    });
  }

  void _stopBufferingIndicator() {
    bufferingDisplayTimer?.cancel();
    displayBufferingIndicator = false;
    update();
  }

  void toggleControlsVisibility() {
    if (hideStuff.value) {
      hideStuff.value = false;
      _startHideTimer();
    } else {
      hideStuff.value = true;
      hideTimer?.cancel();
    }
  }

  void _startHideTimer() {
    hideTimer?.cancel();
    hideTimer = Timer(const Duration(seconds: 3), () {
      hideStuff.value = true;
    });
  }

  void togglePlayPause() {
    if (controller.value.isPlaying) {
      controller.pause();
      hideTimer?.cancel();
    } else {
      controller.play();
      _startHideTimer();
    }
    update();
  }

  void seekToPosition(int position) {
    controller.seekTo(Duration(milliseconds: position));
    update();
  }

  Widget _buildOptionsButton() {
    return IconButton(
      icon: Icon(Icons.more_vert),
      onPressed: () {
        // Options dialog code here
      },
    );
  }

  Widget _buildPlayPauseButton() {
    return IconButton(
      icon: Icon(
        controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
      ),
      onPressed: togglePlayPause,
    );
  }

  Widget _buildMuteButton() {
    return IconButton(
      icon: Icon(
        controller.value.volume > 0 ? Icons.volume_up : Icons.volume_off,
      ),
      onPressed: () {
        if (controller.value.volume > 0) {
          latestVolume = controller.value.volume;
          controller.setVolume(0);
        } else {
          controller.setVolume(latestVolume ?? 0.5);
        }
        update();
      },
    );
  }

  Widget _buildActionBar() {
    return Positioned(
      top: 0,
      right: 0,
      child: SafeArea(
        child: AnimatedOpacity(
          opacity: notifier.hideStuff ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 250),
          child: Row(
            children: [
              // _buildSubtitleToggle(),
              if (chewieController!.showOptions) _buildOptionsButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Expanded(
      child: MaterialVideoProgressBar(
        controller,
        onDragStart: () {
          // setState(() {
          //   _dragging = true;
          // });

          update(){
            dragging = true;
          }

          hideTimer?.cancel();
        },
        onDragUpdate: () {
          hideTimer?.cancel();
        },
        onDragEnd: () {
          // setState(() {
          //   _dragging = false;
          // });
          update(){
            dragging = false;
          }

          _startHideTimer();
        },
        colors: chewieController!.materialProgressColors ??
            ChewieProgressColors(
              playedColor: Theme.of(context).colorScheme.secondary,
              handleColor: Theme.of(context).colorScheme.secondary,
              bufferedColor:
              Theme.of(context).colorScheme.background.withOpacity(0.5),
              backgroundColor: Theme.of(context).disabledColor.withOpacity(.5),
            ),
      ),
    );
  }

  Widget _buildPosition(Color? iconColor) {
    final position = latestValue.position;
    final duration = latestValue.duration;

    return RichText(
      text: TextSpan(
        text: '${formatDuration(position)} ',
        children: <InlineSpan>[
          TextSpan(
            text: '/ ${formatDuration(duration)}',
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.white.withOpacity(.75),
              fontWeight: FontWeight.normal,
            ),
          )
        ],
        style: const TextStyle(
          fontSize: 14.0,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _onExpandCollapse() {
    // setState(() {
    //   notifier.hideStuff = true;
    //   if(null!=widget.function){
    //     widget.function!(true);
    //   }
    //
    //   chewieController.toggleFullScreen();
    //   _showAfterExpandCollapseTimer =
    //       Timer(const Duration(milliseconds: 300), () {
    //         setState(() {
    //           _cancelAndRestartTimer();
    //         });
    //       });
    // });
    notifier.hideStuff = true;
    // if(null!=widget.function){
    //   widget.function!(true);
    // }

    chewieController!.toggleFullScreen();
    showAfterExpandCollapseTimer =
        Timer(const Duration(milliseconds: 300), () {
          // setState(() {
          //   _cancelAndRestartTimer();
          // });
          cancelAndRestartTimer();
          update();
        });
    update();
  }

  GestureDetector _buildExpandButton() {
    return GestureDetector(
      onTap: _onExpandCollapse,
      child: AnimatedOpacity(
        opacity: notifier.hideStuff ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          height: barHeight + (chewieController!.isFullScreen ? 15.0 : 0),
          margin: const EdgeInsets.only(right: 12.0),
          padding: const EdgeInsets.only(
            left: 8.0,
            right: 8.0,
          ),
          child: Center(
            child: Icon(
              chewieController!.isFullScreen
                  ? Icons.fullscreen_exit
                  : Icons.fullscreen,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  AnimatedOpacity _buildBottomBar(
      BuildContext context,
      ) {
    final iconColor = Theme.of(context).textTheme.labelLarge!.color;

    return AnimatedOpacity(
      opacity: notifier.hideStuff ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        height: barHeight + (chewieController!.isFullScreen ? 10.0 : 10.0),
        padding: EdgeInsets.only(
          left: 20,
          bottom: !chewieController!.isFullScreen ? 10.0 : 0,
        ),
        child: SafeArea(
          bottom: chewieController!.isFullScreen,
          minimum: chewieController!.controlsSafeAreaMinimum,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    if (chewieController!.isLive)
                      const Expanded(child: Text('LIVE'))
                    else
                      _buildPosition(iconColor),
                    if (chewieController!.allowMuting)
                      _buildMuteButton(),
                    const Spacer(),
                    if (chewieController!.allowFullScreen) _buildExpandButton(),
                  ],
                ),
              ),
              SizedBox(
                height: chewieController!.isFullScreen ? 15.0 : 15.0,
              ),
              if (!chewieController!.isLive)
                Expanded(
                  child: Container(
                    // 上下左右都设置会导致进度条在竖屏情况下拖动点击失败，被覆盖？ 应该调整整个Column外面的Container的高度
                    // padding: const EdgeInsets.fromLTRB(0, 20, 20, 0), // 上右下左
                    padding: const EdgeInsets.only(right:20), // 上右下左
                    child: Row(
                      children: [
                        _buildProgressBar(),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHitArea() {
    final bool isFinished = latestValue.position >= latestValue.duration;
    final bool showPlayButton = !dragging && !notifier.hideStuff;

    return GestureDetector(
      onTap: () {
        if (latestValue.isPlaying) {
          if (displayTapped) {
            // setState(() {
            //   notifier.hideStuff = true;
              // if(null!=widget.function){
              //   widget.function!(true);
              // }
            // });
            update(){
              notifier.hideStuff = true;
            }
          } else {
            cancelAndRestartTimer();
          }
        } else {
          togglePlayPause();
          update(){
            notifier.hideStuff = true;
          }
          // setState(() {
          //   notifier.hideStuff = true;
            // if(null!=widget.function){
            //   widget.function!(true);
            // }
          // });
        }
      },
      child: CenterPlayButton(
        backgroundColor: Colors.black54,
        iconColor: Colors.white,
        isFinished: isFinished,
        isPlaying: controller.value.isPlaying,
        show: showPlayButton,
        onPressed: togglePlayPause,
      ),
    );
  }

  Future<String> _captureVideoFrame() async {
    // 暂停视频播放
    // await controller.pause();
    togglePlayPause();

    // 获取视频帧
    if (controller.dataSourceType == DataSourceType.file) {
      String dataSource = controller.dataSource;
      Duration currentDuration = latestValue.position;
      // String imagePath = await getFrameAtMoment(dataSource, currentDuration);
      MediaFileData? mediaFileData = await queryMediaDataById(videoId);
      if (null != mediaFileData &&
          null != mediaFileData.path &&
          mediaFileData.path!.isNotEmpty) {
        // String? imagePath = await generateThumbnailImageAtTimeMs(
        String? imagePath = await generateThumbnailImageAtTimeMsByFfmpeg(
            mediaFileData.path!, currentDuration.inMilliseconds);
        if (null == imagePath || imagePath.isEmpty) {
          return "";
        }
        return imagePath;
      }
    }
    return "";
  }

  GestureDetector _buildCameraButton() {
    return GestureDetector(
      // onTap: _captureVideoFrame,
      onTap: () async {
        // 获取视频帧的图片路径
        String imagePath = await _captureVideoFrame();
        // String imagePath = await _captureVideoFrameByVideoPlayerController();
        // 导航到 VideoTagAddPage 页面，并将图片路径传递过去
        Get.to(
          () => Container(
            padding: const EdgeInsets.all(5),
            color: Colors.black.withOpacity(0.5),
            child: VideoTagAddPage(
              videoId: videoId,
              imagePath: imagePath, // 传入图片路径
              mediaMoment: latestValue.position.inMilliseconds, // 传入视频当前播放位置
            ),
          ),
        )?.then((value) {
          // 返回视频播放页面后继续播放视频
          togglePlayPause();
          VideoRelationHorizontalScrollPagingController
              videoRelationHorizontalScrollPagingController =
              Get.find<VideoRelationHorizontalScrollPagingController>();
          // todo liurong 这里有问题，那边数据可能没有入库，这边查不出来 在关联插入界面 等待保存插入之后再回到该页面，应该可以解决该问题
          videoRelationHorizontalScrollPagingController.refreshData();
        });
      },
      child: AnimatedOpacity(
        opacity: notifier.hideStuff ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: Align(
            alignment: Alignment.centerRight,
            child: Icon(
              Icons.camera_outlined,
              color: Colors.white,
              size: 25,
            )),
      ),
    );
  }

  @override
  void onClose() {
    controller.removeListener(_updateState);
    hideTimer?.cancel();
    initTimer?.cancel();
    bufferingDisplayTimer?.cancel();
    super.onClose();
  }
}

// class MaterialControlsBar extends StatelessWidget {
//   final MaterialControlsController controller;
//
//   MaterialControlsBar({required this.controller});
//
//   @override
//   Widget build(BuildContext context) {
//     // return Container(
//     //   height: controller.barHeight,
//     //   margin: EdgeInsets.all(controller.marginSize),
//     //   child: Row(
//     //     children: [
//     //       controller._buildPlayPauseButton(),
//     //       controller._buildMuteButton(),
//     //       controller._buildOptionsButton(),
//     //       controller._buildCameraButton(), // 添加了这一行
//     //       // Add other control buttons and widgets here
//     //     ],
//     //   ),
//     // );
//
//
//   }
// }

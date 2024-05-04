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
import 'package:hamster/widget/video_chewie/video_horizontal_scroll_widget.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../config/id_generator/id_generator.dart';
import '../../file/file_finder_enhanced.dart';
import '../../file/thumbnail_util.dart';
import '../../media_manage/model/po/media_file_data.dart';
import '../../media_manage/service/media_manager_service.dart';
import '../tag/media_tag_add_widget.dart';

/// 直接copy chewie的MaterialControls类，拿来进行魔改 chewie的ChewieController默认用的就是这个MaterialControls
class CustomMaterialControls extends StatefulWidget {
  CustomMaterialControls({
    this.showPlayButton = true,
    required this.videoId,
    required this.videoHorizontalScrollWidget, // 接收传递过来的 Widget
    // 可选参数 seekTo
    this.seekTo,
    Key? key,
  }) : super(key: key);


  final Widget videoHorizontalScrollWidget;
  final bool showPlayButton;
  late int videoId; // 声明 videoId 字段
  final int? seekTo;

  @override
  State<StatefulWidget> createState() {
    return _MaterialControlsState();
  }
}

class _MaterialControlsState extends State<CustomMaterialControls>
    with SingleTickerProviderStateMixin {
  late PlayerNotifier notifier;
  late VideoPlayerValue _latestValue;
  double? _latestVolume;
  Timer? _hideTimer;
  Timer? _initTimer;
  late var _subtitlesPosition = Duration.zero;
  bool _subtitleOn = false;
  Timer? _showAfterExpandCollapseTimer;
  bool _dragging = false;
  bool _displayTapped = false;
  Timer? _bufferingDisplayTimer;
  bool _displayBufferingIndicator = false;

  final barHeight = 48.0 * 1.5;
  final marginSize = 5.0;

  late VideoPlayerController controller;
  ChewieController? _chewieController;

  // We know that _chewieController is set in didChangeDependencies
  ChewieController get chewieController => _chewieController!;

  // late VideoHorizontalScrollPagingController _videoHorizontalScrollPagingController; // 声明 VideoHorizontalScrollPagingController

  @override
  void initState() {
    super.initState();
    notifier = Provider.of<PlayerNotifier>(context, listen: false);
    // 在 initState 方法中初始化 VideoHorizontalScrollPagingController
    // _videoHorizontalScrollPagingController = Get.put(VideoHorizontalScrollPagingController());
  }

  @override
  Widget build(BuildContext context) {
    if (_latestValue.hasError) {
      return chewieController.errorBuilder?.call(
            context,
            chewieController.videoPlayerController.value.errorDescription!,
          ) ??
          const Center(
            child: Icon(
              Icons.error,
              color: Colors.white,
              size: 42,
            ),
          );
    }
    // MouseRegion 这意味着当鼠标指针在 MouseRegion 区域内移动时，将会取消隐藏控件的定时器并重新启动。即检测到移动则显示bar和控制按钮等
    // ->GestureDetector
    // ->AbsorbPointer 用于在其子树中吸收用户输入事件,其 absorbing:notifier.hideStuff 为 true 时，会吸收其子树中的用户输入事件，从而阻止视频播放器控件对用户输入事件的响应。
    // ->Stack
    // ->
    return MouseRegion(
      onHover: (_) {
        _cancelAndRestartTimer();
      },
      child: GestureDetector(
        onTap: () => _cancelAndRestartTimer(),
        /*
        AbsorbPointer 是 Flutter 中的一个小部件，用于在其子树中吸收用户输入事件，从而阻止用户与其子树中的小部件进行交互。当 AbsorbPointer 的 absorbing 属性为 true 时，它会阻止其子树中的小部件接收指针事件。
        这个小部件通常用于在特定情况下禁用用户与某些小部件的交互，比如在显示某些信息时，禁止用户点击按钮或输入框等。
         */
        child: AbsorbPointer(
          absorbing: notifier.hideStuff,
          //  Stack 小部件，它允许将子部件堆叠在一起。在这里，它被用于布局视频播放器控件的各个组成部分。
          child: Stack(
            children: [
              // _displayBufferingIndicator 为 true，则显示一个圆形进度条，用于指示视频正在缓冲。
              if (_displayBufferingIndicator)
                const Center(
                  child: CircularProgressIndicator(),
                )
              else
                //_buildHitArea()，即视频播放区域的命中区域
                _buildHitArea(),
              //这个部分构建了视频播放器的操作栏，用于显示一些操作按钮，比如字幕切换按钮等
              _buildActionBar(),
              // 这里是一个 Column，包含了视频播放器底部的内容。
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  //_subtitleOn 为 true，则会在底部显示字幕。这里使用 Transform.translate 来根据 notifier.hideStuff 的值来控制字幕的显示位置。
                  if (_subtitleOn)
                    Transform.translate(
                      offset: Offset(
                        0.0,
                        notifier.hideStuff ? barHeight * 0.8 : 0.0,
                      ),
                      child:
                          _buildSubtitles(context, chewieController.subtitle!),
                    ),
                  // 构建视频切换列表
                  // _buildVideoList(context),
                  //构建了底部的控制栏，包括播放进度条、音量控制等。
                  _buildBottomBar(context),
                ],
              ),
              // 添加实时截图按钮组件
              // CameraIcon(),
              _buildCameraButton(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _dispose();
    // 不能在这里销毁横向VideoHorizontalScrollPagingController因为全屏的时候也会调用这个dispose
    // _videoHorizontalScrollPagingController.dispose();
    // // 如果这里不调用delete 再次进入播放页面会报错 使用一个已经dispose的controller
    // Get.delete<VideoHorizontalScrollPagingController>();
    super.dispose();
  }

  void _dispose() {
    controller.removeListener(_updateState);
    _hideTimer?.cancel();
    _initTimer?.cancel();
    _showAfterExpandCollapseTimer?.cancel();
    WakelockPlus.disable();
  }

  @override
  void didChangeDependencies() {
    // 进入播放页面 点击播放页面全屏 都会调用
    final oldController = _chewieController;
    _chewieController = ChewieController.of(context);
    controller = chewieController.videoPlayerController;

    if (oldController != chewieController) {
      _dispose();
      _initialize();
    }
    super.didChangeDependencies();
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
              _buildSubtitleToggle(),
              if (chewieController.showOptions) _buildOptionsButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionsButton() {
    final options = <OptionItem>[
      OptionItem(
        onTap: () async {
          Navigator.pop(context);
          _onSpeedButtonTap();
        },
        iconData: Icons.speed,
        title: chewieController.optionsTranslation?.playbackSpeedButtonText ??
            'Playback speed',
      )
    ];

    if (chewieController.additionalOptions != null &&
        chewieController.additionalOptions!(context).isNotEmpty) {
      options.addAll(chewieController.additionalOptions!(context));
    }

    return AnimatedOpacity(
      opacity: notifier.hideStuff ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 250),
      child: IconButton(
        onPressed: () async {
          _hideTimer?.cancel();

          if (chewieController.optionsBuilder != null) {
            await chewieController.optionsBuilder!(context, options);
          } else {
            await showModalBottomSheet<OptionItem>(
              context: context,
              isScrollControlled: true,
              useRootNavigator: chewieController.useRootNavigator,
              builder: (context) => OptionsDialog(
                options: options,
                cancelButtonText:
                    chewieController.optionsTranslation?.cancelButtonText,
              ),
            );
          }

          if (_latestValue.isPlaying) {
            _startHideTimer();
          }
        },
        icon: const Icon(
          Icons.more_vert,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSubtitles(BuildContext context, Subtitles subtitles) {
    if (!_subtitleOn) {
      return const SizedBox();
    }
    final currentSubtitle = subtitles.getByPosition(_subtitlesPosition);
    if (currentSubtitle.isEmpty) {
      return const SizedBox();
    }

    if (chewieController.subtitleBuilder != null) {
      return chewieController.subtitleBuilder!(
        context,
        currentSubtitle.first!.text,
      );
    }

    return Padding(
      padding: EdgeInsets.all(marginSize),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: const Color(0x96000000),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Text(
          currentSubtitle.first!.text.toString(),
          style: const TextStyle(
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  AnimatedOpacity _buildVideoList(BuildContext context) {
    return AnimatedOpacity(
      opacity: notifier.hideStuff ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        height: 100,
        padding: EdgeInsets.all(2),
        width: double.maxFinite,
        // child: VideoHorizontalScrollWidget(),
        // 将相同的 ValueKey 传递给 VideoHorizontalScrollWidget
        // child: VideoHorizontalScrollWidget(
        //   key: const ValueKey<String>('video_horizontal_scroll_key'),
        // ),
        child: widget.videoHorizontalScrollWidget,
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
        height: barHeight + (chewieController.isFullScreen ? 10.0 : 10.0),
        padding: EdgeInsets.only(
          left: 20,
          bottom: !chewieController.isFullScreen ? 10.0 : 0,
        ),
        child: SafeArea(
          bottom: chewieController.isFullScreen,
          minimum: chewieController.controlsSafeAreaMinimum,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    if (chewieController.isLive)
                      const Expanded(child: Text('LIVE'))
                    else
                      _buildPosition(iconColor),
                    if (chewieController.allowMuting)
                      _buildMuteButton(controller),
                    const Spacer(),
                    if (chewieController.allowFullScreen) _buildExpandButton(),
                  ],
                ),
              ),
              SizedBox(
                height: chewieController.isFullScreen ? 15.0 : 15.0,
              ),
              if (!chewieController.isLive)
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

  GestureDetector _buildMuteButton(
    VideoPlayerController controller,
  ) {
    return GestureDetector(
      onTap: () {
        _cancelAndRestartTimer();

        if (_latestValue.volume == 0) {
          controller.setVolume(_latestVolume ?? 0.5);
        } else {
          _latestVolume = controller.value.volume;
          controller.setVolume(0.0);
        }
      },
      child: AnimatedOpacity(
        opacity: notifier.hideStuff ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: ClipRect(
          child: Container(
            height: barHeight,
            padding: const EdgeInsets.only(
              left: 6.0,
            ),
            child: Icon(
              _latestValue.volume > 0 ? Icons.volume_up : Icons.volume_off,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector _buildExpandButton() {
    return GestureDetector(
      onTap: _onExpandCollapse,
      child: AnimatedOpacity(
        opacity: notifier.hideStuff ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          height: barHeight + (chewieController.isFullScreen ? 15.0 : 0),
          margin: const EdgeInsets.only(right: 12.0),
          padding: const EdgeInsets.only(
            left: 8.0,
            right: 8.0,
          ),
          child: Center(
            child: Icon(
              chewieController.isFullScreen
                  ? Icons.fullscreen_exit
                  : Icons.fullscreen,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHitArea() {
    final bool isFinished = _latestValue.position >= _latestValue.duration;
    final bool showPlayButton =
        widget.showPlayButton && !_dragging && !notifier.hideStuff;

    return GestureDetector(
      onTap: () {
        if (_latestValue.isPlaying) {
          if (_displayTapped) {
            setState(() {
              notifier.hideStuff = true;
            });
          } else {
            _cancelAndRestartTimer();
          }
        } else {
          _playPause();

          setState(() {
            notifier.hideStuff = true;
          });
        }
      },
      child: CenterPlayButton(
        backgroundColor: Colors.black54,
        iconColor: Colors.white,
        isFinished: isFinished,
        isPlaying: controller.value.isPlaying,
        show: showPlayButton,
        onPressed: _playPause,
      ),
    );
  }

  Future<void> _onSpeedButtonTap() async {
    _hideTimer?.cancel();

    final chosenSpeed = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: chewieController.useRootNavigator,
      builder: (context) => PlaybackSpeedDialog(
        speeds: chewieController.playbackSpeeds,
        selected: _latestValue.playbackSpeed,
      ),
    );

    if (chosenSpeed != null) {
      controller.setPlaybackSpeed(chosenSpeed);
    }

    if (_latestValue.isPlaying) {
      _startHideTimer();
    }
  }

  Widget _buildPosition(Color? iconColor) {
    final position = _latestValue.position;
    final duration = _latestValue.duration;

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

  Widget _buildSubtitleToggle() {
    //if don't have subtitle hiden button
    if (chewieController.subtitle?.isEmpty ?? true) {
      return const SizedBox();
    }
    return GestureDetector(
      onTap: _onSubtitleTap,
      child: Container(
        height: barHeight,
        color: Colors.transparent,
        padding: const EdgeInsets.only(
          left: 12.0,
          right: 12.0,
        ),
        child: Icon(
          _subtitleOn
              ? Icons.closed_caption
              : Icons.closed_caption_off_outlined,
          color: _subtitleOn ? Colors.white : Colors.grey[700],
        ),
      ),
    );
  }

  void _onSubtitleTap() {
    setState(() {
      _subtitleOn = !_subtitleOn;
    });
  }

  void _cancelAndRestartTimer() {
    _hideTimer?.cancel();
    _startHideTimer();

    setState(() {
      notifier.hideStuff = false;
      _displayTapped = true;
    });
  }

  // void switchVideo(int videoId, String videoPath) {
  // widget.videoId = videoId;
  // _dispose();
  // // 停止当前视频的播放
  // controller.dispose();
  // controller = final FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();
  //
  //   Future<int> getVideoLength(String videoPath) async {
  //     try {
  //       final mediaInformation = await _flutterFFmpeg.getMediaInformation(videoPath);
  //       final duration = mediaInformation.getMediaProperties()['duration'];
  //       final durationInSeconds = (duration != null) ? duration / 1000 : 0;
  //       return durationInSeconds.round();
  //     } catch (e) {
  //       print('Error getting video length: $e');
  //       return 0;
  //     }
  //   }
  //   ..initialize().then((_) {
  //     setState(() {});
  //   });
  // this.chewieController.videoPlayerController = controller;
  // _initialize();
  // widget.videoId = videoId;
  // _dispose();
  // // 停止当前视频的播放
  // controller.dispose();
  // controller = VideoPlayerController.file(File(videoPath))
  //   ..initialize().then((_) {
  //     setState(() {
  //       // 创建一个新的 ChewieController 实例来更新 videoPlayerController
  //       _chewieController = ChewieController(
  //         videoPlayerController: controller,
  //         // 其他 ChewieController 的属性...
  //       );
  //     });
  //   });
  // _initialize();
  // void switchVideo(int videoId, String videoPath) {
  //   widget.videoId = videoId;
  //   _dispose();
  //   // 停止当前视频的播放
  //   controller.dispose();
  //   controller = VideoPlayerController.file(File(videoPath))
  //     ..initialize().then((_) {
  //       setState(() {
  //         _chewieController = _chewieController?.copyWith(
  //           videoPlayerController: controller,
  //         );
  //       });
  //     });
  //   _initialize();
  // }
  // void switchVideo(int videoId, String videoPath) {
  //   widget.videoId = videoId;
  //   _dispose();
  //
  //   // 停止当前视频的播放
  //   controller.dispose();
  //
  //   // 创建新的 VideoPlayerController
  //   controller = VideoPlayerController.file(File(videoPath));
  //
  //   // 初始化新的 VideoPlayerController
  //   controller.initialize().then((_) {
  //     setState(() {
  //       // 使用新的 VideoPlayerController 更新 ChewieController
  //       _chewieController = ChewieController(
  //         videoPlayerController: controller,
  //         // 其他 ChewieController 的属性...
  //       );
  //       // 启动播放器
  //       controller.play();
  //       WakelockPlus.enable();
  //
  //       // 初始化 ChewieController
  //       _initialize();
  //     });
  //   });
  // }

  // }

  Future<void> _initialize() async {
    _subtitleOn = chewieController.subtitle?.isNotEmpty ?? false;
    controller.addListener(_updateState);

    _updateState();

    if (controller.value.isPlaying || chewieController.autoPlay) {
      _startHideTimer();
    }

    if (chewieController.showControlsOnInitialize) {
      _initTimer = Timer(const Duration(milliseconds: 200), () {
        setState(() {
          notifier.hideStuff = false;
        });
      });
    }
    // 如果 seekTo 不为空，并且视频已经初始化，则跳转到指定位置
    if (widget.seekTo != null && controller.value.isInitialized) {
      await controller.seekTo(Duration(milliseconds: widget.seekTo!));
    }
    WakelockPlus.enable();
  }

  void _onExpandCollapse() {
    setState(() {
      notifier.hideStuff = true;

      chewieController.toggleFullScreen();
      _showAfterExpandCollapseTimer =
          Timer(const Duration(milliseconds: 300), () {
        setState(() {
          _cancelAndRestartTimer();
        });
      });
    });
  }

  void _playPause() {
    final isFinished = _latestValue.position >= _latestValue.duration;

    setState(() {
      if (controller.value.isPlaying) {
        notifier.hideStuff = false;
        _hideTimer?.cancel();
        controller.pause();
        // 暂停情况，禁用屏幕常量
        // Wakelock.disable();
        WakelockPlus.disable();
      } else {
        WakelockPlus.enable();
        _cancelAndRestartTimer();

        if (!controller.value.isInitialized) {
          controller.initialize().then((_) {
            controller.play();
            // 启用屏幕常量
            WakelockPlus.enable();
          });
        } else {
          if (isFinished) {
            controller.seekTo(Duration.zero);
          }
          controller.play();
          // 启用屏幕常量
          WakelockPlus.enable();
        }
      }
    });
  }

  void _startHideTimer() {
    final hideControlsTimer = chewieController.hideControlsTimer.isNegative
        ? ChewieController.defaultHideControlsTimer
        : chewieController.hideControlsTimer;
    _hideTimer = Timer(hideControlsTimer, () {
      setState(() {
        notifier.hideStuff = true;
      });
    });
  }

  void _bufferingTimerTimeout() {
    _displayBufferingIndicator = true;
    if (mounted) {
      setState(() {});
    }
  }

  void _updateState() {
    if (!mounted) return;

    // display the progress bar indicator only after the buffering delay if it has been set
    if (chewieController.progressIndicatorDelay != null) {
      if (controller.value.isBuffering) {
        _bufferingDisplayTimer ??= Timer(
          chewieController.progressIndicatorDelay!,
          _bufferingTimerTimeout,
        );
      } else {
        _bufferingDisplayTimer?.cancel();
        _bufferingDisplayTimer = null;
        _displayBufferingIndicator = false;
      }
    } else {
      _displayBufferingIndicator = controller.value.isBuffering;
    }

    setState(() {
      _latestValue = controller.value;
      _subtitlesPosition = controller.value.position;
    });
  }

  Widget _buildProgressBar() {
    return Expanded(
      child: MaterialVideoProgressBar(
        controller,
        onDragStart: () {
          setState(() {
            _dragging = true;
          });

          _hideTimer?.cancel();
        },
        onDragUpdate: () {
          _hideTimer?.cancel();
        },
        onDragEnd: () {
          setState(() {
            _dragging = false;
          });

          _startHideTimer();
        },
        colors: chewieController.materialProgressColors ??
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

  GestureDetector _buildCameraButton() {
    return GestureDetector(
      // onTap: _captureVideoFrame,
      onTap: () async {
        // 获取视频帧的图片路径
        String imagePath = await _captureVideoFrame();
        // String imagePath = await _captureVideoFrameByVideoPlayerController();
        // 导航到 VideoTagAddPage 页面，并将图片路径传递过去
        Navigator.push(
          context,
          MaterialPageRoute(builder: (BuildContext context) {
            return Container(
              padding: const EdgeInsets.all(5),
              color: Colors.black.withOpacity(0.5),
              child: VideoTagAddPage(
                videoId: widget.videoId,
                imagePath: imagePath, // 传入图片路径
                mediaMoment: _latestValue.position.inMilliseconds, // 传入视频当前播放位置
              ),
            );
          }),
        ).then((_) {
          // 返回视频播放页面后继续播放视频
          _playPause();
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

  Future<String> _captureVideoFrame() async {
    // 暂停视频播放
    // await controller.pause();
    _playPause();

    // 获取视频帧
    if (controller.dataSourceType == DataSourceType.file) {
      String dataSource = controller.dataSource;
      Duration currentDuration = _latestValue.position;
      // String imagePath = await getFrameAtMoment(dataSource, currentDuration);
      MediaFileData? mediaFileData = await queryMediaDataById(widget.videoId);
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
    // final image = await controller.position!.image;
    // if (image != null) {
    //   // 将视频帧转换为字节数据
    //   final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    //   if (byteData != null) {
    //     return byteData.buffer.asUint8List();
    //   }
    // }
    return "";
  }
}

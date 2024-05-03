import 'dart:io';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';

Future<void> generateThumbnailByFfmpeg(
    String videoPath, String thumbnailPath, int timeInMilliseconds) async {
  // 设置 FFmpegKit 的日志等级
  // 设置日志等级
  // 设置日志等级
  // 设置日志等级
  // 设置日志等级
  // FFmpegKitConfig.enableLogCallback((log) {
  //   // 通过Log对象获取日志信息
  //   final logMessage = log.getMessage();
  //   // 打印日志
  //   print(logMessage);
  // });

  // 使用 FFprobe 获取视频的元数据
  // final ffprobeResult = await FFprobeKit.execute(
  //     '-i $videoPath -show_streams -print_format json');

  // thumbnailPath = "dsfsd.png";
  // 使用 FFmpeg 生成指定时间点的缩略图
  String format = millisecondsToSSFormat(timeInMilliseconds);
  final thumbnailCommand = '-ss $format -i "$videoPath" -vframes 1 "$thumbnailPath"';
  final ffmpegResult = await FFmpegKit.execute(thumbnailCommand);

  // 检查 FFmpeg 是否成功执行
  ReturnCode? returnCode = await ffmpegResult.getReturnCode();
  if (returnCode != null && returnCode.getValue() == ReturnCode.success) {
    print('Thumbnail generated successfully.');
  } else {
    print('Failed to generate thumbnail.');
  }
}

String millisecondsToSSFormat(int milliseconds) {
  final int seconds = (milliseconds / 1000).truncate();
  final int hours = (seconds / 3600).truncate();
  final int minutes = ((seconds % 3600) / 60).truncate();
  final int remainingSeconds = seconds % 60;
  final int remainingMilliseconds = milliseconds % 1000;

  return '$hours:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}.${remainingMilliseconds.toString().padLeft(3, '0')}';
}

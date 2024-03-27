import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';

Future<void> getFirstFrame(String inputFilePath, String outputImagePath) async {
  try {
    // 使用 FFmpeg 命令获取第一帧图片
    FFmpegKit.execute('-i $inputFilePath -vframes 1 $outputImagePath').then((session) async {
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        // 执行成功，你可以在这里处理输出图片的路径（outputImagePath）
        print('成功获取第一帧图片');
      } else if (ReturnCode.isCancel(returnCode)) {
        // 操作被取消
        print('操作被取消');
      } else {
        // 发生错误
        print('执行命令时发生错误');
      }
    });
  } catch (e) {
    print('Error: $e');
  }

}

Future<String> getFrameAtMoment(String inputFilePath, Duration duration) async {
  try {
    String outputImagePath = "/storage/emulated/0/Download/"+DateTime.now().millisecondsSinceEpoch.toString()+".jpg";
    // 将持续时间转换为视频起始时间的格式（HH:MM:SS.sss）
    String startTime = _formatDuration(duration);

    // 使用 FFmpeg 命令获取指定时刻的视频帧
    FFmpegSession session = await FFmpegKit.execute('-ss $startTime -i $inputFilePath -vframes 1 $outputImagePath');
    final returnCode = await session.getReturnCode();
    final output = await session.getAllLogs();

    if (ReturnCode.isSuccess(returnCode)) {
      // 执行成功，你可以在这里处理输出图片的路径（outputImagePath）
      print('成功获取指定时刻的视频帧');
      print(output); // 打印 FFmpeg 日志
      return outputImagePath;
    } else if (ReturnCode.isCancel(returnCode)) {
      // 操作被取消
      print('操作被取消');
      print(output); // 打印 FFmpeg 日志
      return outputImagePath;
    } else {
      // 发生错误
      print('执行命令时发生错误');
      print(output); // 打印 FFmpeg 日志
      return outputImagePath;
    }
    // FFmpegKit.execute('-ss $startTime -i $inputFilePath -vframes 1 $outputImagePath').then((session) async {
    //   final returnCode = await session.getReturnCode();
    //   final output = await session.getAllLogs(); // 获取 FFmpeg 日志
    //
    // });
  } catch (e) {
    print('Error: $e');
  }
  return "";
}

String _formatDuration(Duration duration) {
  // 获取持续时间的小时、分钟、秒和毫秒
  int hours = duration.inHours;
  int minutes = duration.inMinutes.remainder(60);
  int seconds = duration.inSeconds.remainder(60);
  int milliseconds = duration.inMilliseconds.remainder(1000);

  // 将时间格式化为字符串
  String formattedDuration = '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${milliseconds.toString().padLeft(3, '0')}';

  return formattedDuration;
}
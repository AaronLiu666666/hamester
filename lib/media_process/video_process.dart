import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
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

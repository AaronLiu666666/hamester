import 'dart:io';

import 'package:video_thumbnail/video_thumbnail.dart';

import '../config/id_generator/id_generator.dart';
import 'file_finder_enhanced.dart';

Future<String?> generateThumbnailImage(String videoPath) async {
  try {
    String path = await getPicStorePath();
    String thumbnailPath = path + UuidGenerator.generateUuid() + ".png";
    final fileName = await VideoThumbnail.thumbnailFile(
      video: videoPath,
      thumbnailPath: thumbnailPath,
      // imageFormat: imageFormat,
      // quality: quality,
      // maxWidth: maxWidth,
      // maxHeight: maxHeight,
      // timeMs: timeMs,
      // thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.PNG,
      // maxHeight: 64, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
      quality: 100,
    );

    // File file = File(thumbnailPath);
    return thumbnailPath;
  } catch(e){
    print("生成缩略图失败: $e");
    return null;
  }
}

import 'dart:io';

import 'package:video_thumbnail/video_thumbnail.dart';

import '../config/id_generator/id_generator.dart';
import '../media_manage/model/po/media_file_data.dart';
import '../media_manage/service/media_manager_service.dart';
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
  } catch (e) {
    print("生成缩略图失败: $e");
    return null;
  }
}

Future<void> generateMediaListThumbnailImages(List<MediaFileData> list) async {
  // 列表不为空，在加载列表数据的时候，生成缩略图
  if (list.isNotEmpty) {
    // 使用 Future.forEach 来异步处理列表中的每个媒体文件
    await Future.forEach(list, (MediaFileData mediaFileData) async {
      String? path = mediaFileData.path;
      if (null == path || path.isEmpty) {
        // 生成缩略图
        String? thumbnailImagePath =
            await generateThumbnailImage(mediaFileData.path ?? "");
        // 在这里可以对每个缩略图进行处理，比如保存路径或其他操作
        mediaFileData.cover = thumbnailImagePath;
        // 更新数据库封面图片地址
        updateMediaFileData(mediaFileData);
      }
    });
  }
}
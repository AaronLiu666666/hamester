import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../widget/video_chewie/video_chewie_page.dart';

class CardContentData {
  final int id;
  final String path;
  final String fileName;
  final String url;
  final String? text;

  CardContentData(
      {required this.id,
      required this.path,
      required this.fileName,
      required this.url,
      required this.text});
}

class CardContentWidget extends StatelessWidget {
  CardContentData data;

  CardContentWidget({required this.data});

  @override
  Widget build(BuildContext context) {
    // 构建本地文件路径
    return Column(
      children: <Widget>[
        Expanded(
          flex: 1,
          child:
          Image.file(File(data.url), fit: BoxFit.cover),
        ),
        // 2024-04-18 使用Tooltip包裹text，手指在上面是悬浮提示message的内容，为了解决文件名过长占空间问题
        Tooltip(
          message: data.text ?? "", // 提示框中显示完整的文本内容
          child: Text(
            data.text ?? "",
            // 最多展示1行，超过省略展示，防止文字过多展示时占用了图片的空间，导致图片显示过小或者展示不出来问题
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center, // 文字居中显示
          ),
        ),
      ],
    );
  }
}

class CardWidget extends StatelessWidget {
  CardContentData data;

  CardWidget({required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) =>
          //         VideoChewiePage(videoId: data.id, videoPath: data.path),
          //   ),
          // );
          Get.to(
                () => VideoChewiePage(
              videoId: data.id!,
              videoPath: data.path!,
              videoPageFromType: VideoPageFromType.media_page,
            ),
            binding: BindingsBuilder(() {
              Get.put(VideoChewiePageController());
            }),
          );
        },
        child: Card(
          margin: EdgeInsets.all(10),
          child: CardContentWidget(data: data),
        ));
  }
}

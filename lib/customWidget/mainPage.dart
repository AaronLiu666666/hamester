import 'dart:io';
import 'package:flutter/material.dart';
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
          child: Image.file(File(data.url), fit: BoxFit.cover),
        ),
        Text(data.text ?? ""),
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  VideoChewiePage(videoId: data.id, videoPath: data.path),
            ),
          );
        },
        child: Card(
          margin: EdgeInsets.all(10),
          child: CardContentWidget(data: data),
        ));
  }
}

class MainPageWidget extends StatelessWidget {
  List<CardContentData> datas;

  MainPageWidget({required this.datas});

  @override
  Widget build(BuildContext context) {
    int crossAxisCount = 2; // 设置网格列数
    return GridView.count(
      crossAxisCount: crossAxisCount,
      children: datas.map((data) => CardWidget(data: data)).toList(),
    );
  }
}

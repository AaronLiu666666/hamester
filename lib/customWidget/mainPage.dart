import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hamster/widget/video/video_player_page.dart';

import '../widget/VideoPlayWidget.dart';

// List list = [{
//   "url": "https://picx.zhimg.com/50/v2-139627556961d50c4f9b27badce0b99e_720w.jpg?source=1def8aca",
//   "text": "文本1"
// },
//   {
//     "url": "https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/c88ef038299047228439ccc9a7f713cf~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp?",
//     "text": "文本1"
//   },
//   {
//     "url": "https://picx.zhimg.com/50/v2-139627556961d50c4f9b27badce0b99e_720w.jpg?source=1def8aca",
//     "text": "文本1"
//   },
//   {
//     "url": "https://picx.zhimg.com/50/v2-139627556961d50c4f9b27badce0b99e_720w.jpg?source=1def8aca",
//     "text": "文本1"
//   },
// ];

List list = [
  {"url": "assets/image/image_1.png", "text": "文本1"},
  {"url": "assets/image/image_2.png", "text": "文本1"},
  {"url": "assets/image/image_2.png", "text": "文本1"},
  {"url": "assets/image/image_1.png", "text": "文本1"},
];

class CardContentData {
  final int id;
  final String path;
  final String fileName;
  final String url;
  final String? text;

  CardContentData({
    required this.id,
    required this.path,
    required this.fileName,
    required this.url, required this.text});
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
          Navigator.pushNamed(context, '/videoPlay', arguments: {
            "videoSource": data.path,
          });
        },
        onLongPress: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              // builder: (context) => VideoApp(videoSource: data.url),
              builder: (context) => VideoPlayerPage(videoUrl: data.url),
            ),
          );
        },
        child: Card(
          margin: EdgeInsets.all(10),
          child: CardContentWidget(data: data),
        ));
    // return Card(
    //   margin: EdgeInsets.all(10),
    //   child: CardContentWidget(data: data),
    // );
  }
}

class MainPageWidget extends StatelessWidget {
  List<CardContentData> datas;

  MainPageWidget({required this.datas});

  @override
  Widget build(BuildContext context) {
    // return GridView.builder(
    //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    //     crossAxisCount: 2,
    //     childAspectRatio: 1,
    //   ),
    //   itemCount: datas.length,
    //   itemBuilder: (context, index) {
    //     return CardWidget(data: datas[index]);
    //   },
    // );
    // return GridView.count(
    //   crossAxisCount: 2, // numberOfColumns 为你的网格列数
    //   childAspectRatio: 1.0,
    //   children: datas.map((data) => CardWidget(data: data)).toList(),
    // );
    int crossAxisCount = 2; // 设置网格列数
    return GridView.count(
      crossAxisCount: crossAxisCount,
      children: datas.map((data) => CardWidget(data: data)).toList(),
    );
  }
}

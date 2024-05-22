import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../tag_manage/tag_manage_service.dart';
import '../video_chewie/video_relation_horizontal_scroll_wdiget.dart';

/// 视频截图添加视频标签页面
class VideoTagAddPage extends StatefulWidget {
  final int videoId;
  final String imagePath;
  final int mediaMoment;

  VideoTagAddPage({required this.videoId,required this.imagePath,required this.mediaMoment});

  @override
  _VideoTagAddPageState createState() => _VideoTagAddPageState();
}

class _VideoTagAddPageState extends State<VideoTagAddPage> {
  String tagName = '';
  String description = '';

  @override
  void initState() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('添加视频标签'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 展示传入的图片
            Container(
              height: 200, // 设置图片高度
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: FileImage(File(widget.imagePath)),
                  fit: BoxFit.cover, // 图片填充方式
                ),
              ),
            ),
            SizedBox(height: 20), // 图片和输入框之间的间距
            // 第一个输入框：标签名称
            TextFormField(
              onChanged: (value) {
                setState(() {
                  tagName = value;
                });
              },
              decoration: InputDecoration(
                labelText: '标签名称',
                border: OutlineInputBorder(), // 输入框边框样式
              ),
            ),
            SizedBox(height: 10), // 输入框之间的间距
            // 第二个输入框：描述内容
            TextFormField(
              onChanged: (value) {
                setState(() {
                  description = value;
                });
              },
              decoration: InputDecoration(
                labelText: '描述内容',
                border: OutlineInputBorder(), // 输入框边框样式
              ),
              maxLines: null, // 设置为null，可以自动增长
            ),
            SizedBox(height: 20), // 输入框和按钮之间的间距
            // 提交按钮
            ElevatedButton(
              onPressed: () async {
                // 提交按钮逻辑，这里可以使用 tagName 和 description 变量
                print('标签名称：$tagName');
                print('描述内容：$description');
                if(null==tagName||tagName.isEmpty||tagName.contains("//")){
                  Get.snackbar('失败', '标签名不能为空');
                  return;
                }
                await createMediaTagRelation(CreateMediaTagRelationDTO(
                  mediaId: widget.videoId,
                  tagName: tagName,
                  description: description,
                  picPath: widget.imagePath,
                  mediaMoment: widget.mediaMoment
                ));
                // VideoRelationHorizontalScrollPagingController videoRelationHorizontalScrollPagingController = Get.find<VideoRelationHorizontalScrollPagingController>();
                // videoRelationHorizontalScrollPagingController.refreshData();
                // 返回上一个页面
                Navigator.pop(context);
              },
              child: Text('保存'),
            ),
          ],
        ),
      ),
    );
  }
}

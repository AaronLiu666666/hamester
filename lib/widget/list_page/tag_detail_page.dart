import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hamster/media_manage/model/po/media_file_data.dart';
import 'package:image_picker/image_picker.dart';

import '../../media_manage/service/media_manager_service.dart';
import '../../relation_manage/relation_manage_service.dart';
import '../../tag_manage/model/po/media_tag_relation.dart';
import '../../tag_manage/model/po/tag_info.dart';
import '../../tag_manage/tag_manage_service.dart';

/// 详情编辑页面
class TagDetailPage extends StatefulWidget {
  final String id;

  const TagDetailPage({required this.id});

  @override
  _TagDetailPageState createState() => _TagDetailPageState();
}

class _TagDetailPageState extends State<TagDetailPage> {
  late TagInfo _tagInfo; // 存储标签信息的变量
  late List<MediaFileData> _mediaList; // 存储视频列表
  late List<MediaTagRelation> _relationList; // 存储关联的列表
  late List<String> _picPath = [];

  late TextEditingController _tagNameController;
  late TextEditingController _tagDescController;

  @override
  void initState() {
    super.initState();
    // 初始化控制器
    _tagNameController = TextEditingController();
    _tagDescController = TextEditingController();
    // 加载数据
    loadData();
  }

  @override
  void dispose() {
    // 释放控制器
    _tagNameController.dispose();
    _tagDescController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    // 根据ID查询数据的过程
    TagInfo? tagInfo = await queryDataById(widget.id);
    if (tagInfo == null) {
      return;
    }

    // 根据ID查询tag绑定关系
    List<MediaTagRelation> relations = await queryRelationsByTagId(widget.id);
    Set<int> mediaIds = relations
        .where((relation) => relation.mediaId != null) // 过滤掉mediaId为null的关系
        .map((relation) => relation.mediaId!) // 提取mediaId
        .toSet(); // 转换为set

    // 根据ID查询绑定该tag的视频列表
    List<MediaFileData> mediaList = await queryDatasByIds(List.from(mediaIds));
    setState(() {
      _tagInfo = tagInfo;
      _mediaList = mediaList;
      _relationList = relations;
      if (null != tagInfo.tagPic) {
        if(tagInfo.tagPic!.isNotEmpty) {
          _picPath = tagInfo.tagPic!.split(',');
        }
      }
      // 更新控制器中的数据
      _tagNameController.text = _tagInfo.tagName ?? '';
      _tagDescController.text = _tagInfo.tagDesc ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('标签详情'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _tagNameController,
              decoration: InputDecoration(labelText: '标签名称'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _tagDescController,
              decoration: InputDecoration(labelText: '标签描述'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton.icon(
              onPressed: () {
                _showImageSelectionDialog();
              },
              icon: Icon(Icons.add),
              label: Text('添加图片'),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: _picPath.length,
                itemBuilder: (context, index) {
                  final pic = _picPath[index];
                  return Row(
                    children: [
                      Expanded(child: Image.file(File(pic))),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _removeImage(index);
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                saveChanges();
              },
              child: Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageSelectionDialog() {
    _addImage();
  }

  void _addImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _picPath.add(pickedFile.path);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _picPath.removeAt(index);
    });
  }

  Future<void> saveChanges() async {
    String editedTagName = _tagNameController.text;
    String editedTagDesc = _tagDescController.text;
    _tagInfo.tagName = editedTagName;
    _tagInfo.tagDesc = editedTagDesc;
    _tagInfo.tagPic = _picPath.join(",");
    _tagInfo.updateTime = DateTime.now().millisecondsSinceEpoch;
    // 更新tag
    await updateData(_tagInfo);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('保存成功')),
    );
  }
}

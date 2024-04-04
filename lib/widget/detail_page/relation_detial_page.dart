import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hamster/media_manage/model/po/media_file_data.dart';
import 'package:hamster/tag_manage/model/po/media_tag_relation.dart';
import 'package:hamster/tag_manage/model/po/tag_info.dart';

import '../../config/config_manage/config_manage.dart';
import '../../media_manage/service/media_manager_service.dart';
import '../../relation_manage/relation_manage_service.dart';
import '../../tag_manage/tag_manage_service.dart';
import '../video_chewie/video_chewie_page.dart';

/// 关联详情页面
class RelationDetailPage extends StatefulWidget {
  final String id;

  const RelationDetailPage({required this.id});

  @override
  _RelationDetailPageState createState() => _RelationDetailPageState();
}

class _RelationDetailPageState extends State<RelationDetailPage> {
  late MediaTagRelation _relation;

  late TagInfo _tagInfo;

  late MediaFileData _media;

  late TextEditingController _descriptionController;

  bool _isLoading = true; // 添加加载状态

  @override
  void initState() {
    super.initState();
    loadData();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  // 加载数据
  Future<void> loadData() async {
    MediaTagRelation? relation = await queryRelationById(widget.id);
    String? tagId = relation!.tagId;
    int? mediaId = relation!.mediaId;
    TagInfo? tag = await queryDataById(tagId!);
    MediaFileData? media = await queryMediaDataById(mediaId!);
    setState(() {
      _relation = relation;
      _tagInfo = tag!;
      _media = media!;
      _descriptionController.text = _relation.relationDesc ?? '';
      _isLoading = false; // 加载完成后设置为false
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // 显示加载指示器
      return Scaffold(
        appBar: AppBar(
          title: Text('关联详情'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('关联详情'),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.file(
                  File(_relation.mediaMomentPic!),
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: '描述'),
                  maxLines: null,
                ),
                SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoChewiePage(
                          videoId: _media.id!,
                          videoPath: _media.path!,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.file(
                            File(_media.cover!),
                            fit: BoxFit.contain,
                          ),
                          SizedBox(height: 16),
                          Text(
                            _media.fileName ?? '',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          saveDescription();
        },
        child: Icon(Icons.save),
      ),
    );
  }

  void saveDescription() async {
    _relation.relationDesc = _descriptionController.text;
    await updateRelation(_relation);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('描述已保存')),
    );
  }
}

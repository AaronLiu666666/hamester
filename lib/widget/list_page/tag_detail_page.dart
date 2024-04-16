import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hamster/media_manage/model/po/media_file_data.dart';
import 'package:image_picker/image_picker.dart';

import '../../file/thumbnail_util.dart';
import '../../media_manage/service/media_manager_service.dart';
import '../../relation_manage/relation_manage_service.dart';
import '../../tag_manage/model/po/media_tag_relation.dart';
import '../../tag_manage/model/po/tag_info.dart';
import '../../tag_manage/tag_manage_service.dart';
import '../custom_widget/custom_toggle_button_widget.dart';
import '../video_chewie/video_chewie_page.dart';

/// 详情编辑页面
class TagDetailPage extends StatefulWidget {
  final String id;

  const TagDetailPage({super.key, required this.id});

  @override
  _TagDetailPageState createState() => _TagDetailPageState();
}

class _TagDetailPageState extends State<TagDetailPage> {
  late TagInfo _tagInfo; // 存储标签信息的变量
  late List<MediaFileData> _mediaList; // 存储视频列表
  late List<MediaTagRelation> _relationList; // 存储关联的列表
  late List<String> _picPath = [];
  late Map<String,MediaFileData> _relationMediaMap = {};

  late TextEditingController _tagNameController;
  late TextEditingController _tagDescController;

  int _selectedIndex = 0; // 用于存储选中的列表索引

  bool _isLoading = true; // 添加加载状态

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
    await generateMediaListThumbnailImages(mediaList);

    Map<int, MediaFileData> mediaMap = {};

    // 将视频列表按照id映射到mediaMap中
    for (var media in mediaList) {
      mediaMap[media.id!] = media;
    }

    // 将关联关系列表按照id映射到relationMap中
    for (var relation in relations) {
      if (relation.mediaId != null) {
        MediaFileData? mediaFileData = mediaMap[relation.mediaId!];
        if(null!=mediaFileData){
          _relationMediaMap[relation.id!] = mediaFileData;
        }
      }
    }
    setState(() {
      _tagInfo = tagInfo;
      _mediaList = mediaList;
      _relationList = relations;
      if (null != tagInfo.tagPic) {
        if (tagInfo.tagPic!.isNotEmpty) {
          _picPath = tagInfo.tagPic!.split(',');
        }
      }
      // 更新控制器中的数据
      _tagNameController.text = _tagInfo.tagName ?? '';
      _tagDescController.text = _tagInfo.tagDesc ?? '';
      _isLoading = false; // 加载完成后设置为false
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // 显示加载指示器
      return Scaffold(
        appBar: AppBar(
          title: Text('标签详情'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('标签详情：${_tagInfo.tagName ?? ""}'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // 添加 ToggleButtons
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     Expanded(
          //       child: ToggleButtons(
          //         children: [
          //           Expanded(child: Text('关联列表')),
          //           Expanded(child: Text('视频列表')),
          //           Expanded(child: Text('详情')),
          //         ],
          //         isSelected: [
          //           0 == _selectedIndex,
          //           1 == _selectedIndex,
          //           2 == _selectedIndex
          //         ],
          //         onPressed: (int index) {
          //           setState(() {
          //             _selectedIndex = index;
          //           });
          //         },
          //         selectedColor: Colors.blue, // 设置选中状态下的颜色
          //         color: Colors.grey, // 设置非选中状态下的颜色
          //         borderColor: Colors.grey, // 设置边框颜色
          //         selectedBorderColor: Colors.blue, // 设置选中状态下的边框颜色
          //       ),
          //     ),
          //   ],
          // ),
          CustomToggleButtons(
            labels: ['关联列表', '视频列表', '详情'],
            isSelected: [
              _selectedIndex == 0,
              _selectedIndex == 1,
              _selectedIndex == 2,
            ],
            onPressed: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          // 根据选中的索引渲染对应的列表
          if (_selectedIndex == 0) ...[
            _buildRelationList(),
          ] else if (_selectedIndex == 1) ...[
            _buildMediaList(),
          ] else ...[
            _buildTagDetail(),
          ],
        ]),
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

  Widget _buildRelationList() {
    // Wrap the GridView.count in an Expanded to ensure it occupies the available space
    return Expanded(
      child: GridView.count(
        crossAxisCount: 2,
        children: List.generate(_relationList.length, (index) {
          MediaTagRelation data = _relationList[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoChewiePage(
                    videoId: _relationMediaMap[data.id!]!.id!,
                    videoPath: _relationMediaMap[data.id!]!.path!,
                    seekTo: data.mediaMoment,
                  ),
                ),
              );
            },
            onLongPress: () {},
            child: Card(
              margin: EdgeInsets.all(10),
              child: Column(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: _buildImageWidget(data.mediaMomentPic),
                  ),
                  Text(data.relationDesc ?? ""),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMediaList() {
    return Expanded(
        child: GridView.count(
      crossAxisCount: 2,
      children: List.generate(_mediaList.length, (index) {
        // Access each TagInfo object from the tagInfoList
        MediaFileData data = _mediaList[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VideoChewiePage(
                  videoId: data.id!,
                  videoPath: data.path!,
                ),
              ),
            );
          },
          onLongPress: () {},
          child: Card(
            margin: EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: _buildImageWidget(data.cover),
                ),
                Text(data.fileName ?? ""),
              ],
            ),
          ),
        );
      }),
    ));
  }

  Widget _buildTagDetail() {
    return Column(
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
        Container(
          height: 200.0, // 设置适当的高度
          child: ListView.builder(
            shrinkWrap: false, // 设置为 false
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
    );
  }

  Widget _buildImageWidget(String? imagePath) {
    if (imagePath != null && imagePath.isNotEmpty) {
      List<String> imagePaths = imagePath.split(',');
      // 如果路径不为空，则加载文件中的图片
      return SizedBox(
        width: 80.0,
        height: 80.0,
        child: Image.file(File(imagePaths[0]), fit: BoxFit.cover),
      );
    } else {
      // 否则加载默认的空图片
      return SizedBox(
        width: 80.0,
        height: 80.0,
        child: Image.asset('assets/image/no-pictures.png', fit: BoxFit.cover),
      );
    }
  }
}

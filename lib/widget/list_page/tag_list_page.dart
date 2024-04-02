import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hamster/tag_manage/tag_manage_service.dart';
import 'package:hamster/widget/list_page/tag_detail_page.dart';

import '../../tag_manage/model/dto/search_dto.dart';
import '../../tag_manage/model/po/tag_info.dart';

/// 标签列表页面
class TagListPage extends StatefulWidget {
  @override
  _TagListPageState createState() => _TagListPageState();
}

class _TagListPageState extends State<TagListPage> {
  List<TagInfo> tagInfoList = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    List<TagInfo> tagInfoListFromDb = await getTagData(SearchDTO());
    // todo 如果图片为空 则查询关联关系的图片

    setState(() {
      tagInfoList = tagInfoListFromDb;
    });
  }

  @override
  Widget build(BuildContext context) {
    int crossAxisCount = 2; // 设置网格列数
    return GridView.count(
      crossAxisCount: crossAxisCount,
      children: List.generate(tagInfoList.length, (index) {
        // Access each TagInfo object from the tagInfoList
        TagInfo data = tagInfoList[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TagDetailPage(id:data.id!),
              ),
            ).then((_) {
              // 在返回到该页面时重新获取数据并更新列表
              _fetchData();
            });
          },
          onLongPress: () {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => VideoChewiePage(videoId:data.id,videoPath: data.path),
            //   ),
            // );
          },
          child: Card(
            margin: EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: _buildImageWidget(data.tagPic),
                ),
                Text(data.tagName ?? ""),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildImageWidget(String? imagePath) {
    if (imagePath != null && imagePath.isNotEmpty) {
      List<String> imagePaths = imagePath.split(',');
      // 如果路径不为空，则加载文件中的图片
      return Image.file(File(imagePaths[0]), fit: BoxFit.cover);
    }
    else {
      // 否则加载默认的空图片
      return Image.asset('assets/image/no-pictures.png');
    }
  }
}

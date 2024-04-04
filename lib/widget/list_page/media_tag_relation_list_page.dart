
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../relation_manage/relation_manage_service.dart';
import '../../tag_manage/model/dto/search_dto.dart';
import '../../tag_manage/model/po/media_tag_relation.dart';
import '../detail_page/relation_detial_page.dart';


/// 媒体标签关联关系页面
class MediaTagRelationListPage extends StatefulWidget {

  @override
  _MediaTagRelationListPage createState()=>_MediaTagRelationListPage();

}

class _MediaTagRelationListPage extends State<MediaTagRelationListPage> {

  List<MediaTagRelation> relationList = [];

  Future<void> _fetchData() async {
    List<MediaTagRelation> relationInfoListFromDb = await getRelationInfo(SearchDTO());
    setState(() {
      relationList = relationInfoListFromDb;
    });
  }


  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    int crossAxisCount = 2; // 设置网格列数
    return GridView.count(
      crossAxisCount: crossAxisCount,
      children: List.generate(relationList.length, (index) {
        // Access each TagInfo object from the tagInfoList
        MediaTagRelation data = relationList[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RelationDetailPage(id:data.id!),
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
                  child: _buildImageWidget(data.mediaMomentPic),
                ),
                Text(data.relationDesc ?? ""),
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
    } else {
      // 否则加载默认的空图片
      return Image.asset('assets/image/no-pictures.png');
    }
  }

}


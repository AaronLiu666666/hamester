
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hamster/widget/list_page/page_util/page_util.dart';

import '../../relation_manage/relation_manage_service.dart';
import '../../tag_manage/model/dto/search_dto.dart';
import '../../tag_manage/model/po/media_tag_relation.dart';
import '../detail_page/relation_detial_page.dart';
import 'media_home_page.dart';


/// 媒体标签关联关系页面
class RelationPageListPage extends StatefulWidget {

  @override
  _RelationPageListPage createState()=>_RelationPageListPage();

}

class _RelationPageListPage extends State<RelationPageListPage> {

  @override
  void initState() {
    super.initState();
  }


  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RelationPagingController>(
      init: RelationPagingController(),
      builder: (controller){
        return buildRefreshListWidget<MediaTagRelation,RelationPagingController>(
            itemBuilder: (data,index)=>GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RelationDetailPage(id:data.id!),
                  ),
                );
                // .then((_) {
                //   controller.refreshDataNotScan();
                // });
              },
              onLongPress: () {
              },
              child: Card(
                margin: EdgeInsets.all(10),
                child: Column(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: _buildImageWidget(data.mediaMomentPic),
                    ),
                    Tooltip(
                      message: data.relationDesc != null && data.relationDesc!.isNotEmpty ? data.relationDesc! : (data.tagName ?? ""), // 提示框中显示完整的文本内容
                      child: Text(
                        data.relationDesc != null && data.relationDesc!.isNotEmpty ? data.relationDesc! : (data.tagName ?? ""),
                        // 最多展示1行，超过省略展示，防止文字过多展示时占用了图片的空间，导致图片显示过小或者展示不出来问题
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center, // 文字居中显示
                      ),
                    ),
                  ],
                ),
              ),
            ),
            enablePullDown: true,
            enablePullUp: true,
            physics: AlwaysScrollableScrollPhysics(),
            onItemClick: (data,index){
            }
        );
      },
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
class RelationPagingController extends PagingController<MediaTagRelation,PagingState<MediaTagRelation>>{
  @override
  PagingState<MediaTagRelation> getState() {
    return PagingState<MediaTagRelation>()..refreshId = this;
  }

  @override
  Future<void> initBeforeLoadData() async {
  }

  @override
  Future<PagingData<MediaTagRelation>?> loadData(PagingParams pagingParams) async {
    CustomSearchController searchController = Get.find<CustomSearchController>();
    SearchDTO homepageSearchDTO = searchController.getSearchDTO();
    SearchDTO searchDTO = SearchDTO(
      page: pagingParams.current,
      pageSize:pagingParams.size,
      content: homepageSearchDTO.content,
    );
    int total = await searchRelationCount(searchDTO);
    final List<MediaTagRelation> list = await searchRelationPage(searchDTO);
    int pages = (total/pagingParams.size).ceil();
    return PagingData<MediaTagRelation>()
      ..current = pagingParams.current
      ..pages = pages
      ..data = list
      ..size = pagingParams.size // 设置每页数据量
      ..total = total;
  }

}

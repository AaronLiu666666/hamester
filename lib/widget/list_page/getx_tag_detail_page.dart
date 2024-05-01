import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

class GetxTagDetailController extends GetxController {
  TagInfo tagInfo= TagInfo();
  late List<MediaFileData> mediaList;
  late List<MediaTagRelation> relationList;
  late List<String> picPath = [];
  late Map<String, MediaFileData> relationMediaMap = {};

  final id = ''.obs;
  final isLoading = true.obs;
  final selectedIndex = 0.obs; // 用于存储选中的列表索引

  final TextEditingController tagNameController = TextEditingController();
  final TextEditingController tagDescController = TextEditingController();

  List<MediaFileData> getMediaList(){
    return mediaList;
  }

  List<MediaTagRelation> getRelationList(){
    return relationList;
  }

  Map<String, MediaFileData> getRelationMediaMap(){
    return relationMediaMap;
  }

  @override
  void onInit() {
    super.onInit();
    id.value = Get.arguments;
    loadData();
  }


  @override
  void onClose() {
    tagNameController.dispose();
    tagDescController.dispose();
  }

  Future<void> loadData() async {
    try {
      tagInfo = await queryDataById(id.value)??TagInfo();
      relationList = await queryRelationsByTagId(id.value);
      final mediaIds = relationList
          .where((relation) => relation.mediaId != null)
          .map((relation) => relation.mediaId!)
          .toSet();
      mediaList = await queryDatasByIds(List.from(mediaIds));
      await generateMediaListThumbnailImages(mediaList);

      final mediaMap = Map.fromIterable(mediaList, key: (e) => e.id);
      for (var relation in relationList) {
        if (relation.mediaId != null) {
          final mediaFileData = mediaMap[relation.mediaId!];
          if (mediaFileData != null) {
            relationMediaMap[relation.id!] = mediaFileData;
          }
        }
      }

      tagNameController.text = tagInfo.tagName ?? '';
      tagDescController.text = tagInfo.tagDesc ?? '';
      if (tagInfo.tagPic != null && tagInfo.tagPic!.isNotEmpty) {
        picPath = tagInfo.tagPic!.split(',');
      }
    } finally {
      isLoading.value = false;
    }
  }

  void addImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      picPath.add(pickedFile.path);
    }
  }

  void removeImage(int index) {
    picPath.removeAt(index);
  }

  Future<void> saveChanges() async {
    tagInfo.tagName = tagNameController.text;
    tagInfo.tagDesc = tagDescController.text;
    tagInfo.tagPic = picPath.join(",");
    tagInfo.updateTime = DateTime.now().millisecondsSinceEpoch;
    await updateData(tagInfo);
    Get.snackbar('成功', '保存成功');
  }
}

class GetxTagDetailPage extends GetView<GetxTagDetailController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('标签详情: ${controller.tagInfo.tagName ?? ""}'),
      ),
      body: Obx(
        () => controller.isLoading.value
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomToggleButtons(
                      labels: ['关联列表', '视频列表', '详情'],
                      isSelected: [
                        controller.selectedIndex.value == 0,
                        controller.selectedIndex.value == 1,
                        controller.selectedIndex.value == 2,
                      ],
                      onPressed: (int index) {
                        controller.selectedIndex.value = index;
                      },
                    ),
                    if (controller.selectedIndex.value == 0)
                      _buildRelationList()
                    else if (controller.selectedIndex.value == 1)
                      _buildMediaList()
                    else
                      _buildTagDetail(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildRelationList() {
    return Expanded(
      child: GridView.count(
        crossAxisCount: 2,
        children: List.generate(controller.relationList.length, (index) {
          MediaTagRelation data = controller.relationList[index];
          return GestureDetector(
            onTap: () {
              Get.to(
                () => VideoChewiePage(
                  videoId: controller.relationMediaMap[data.id!]!.id!,
                  videoPath: controller.relationMediaMap[data.id!]!.path!,
                  seekTo: data.mediaMoment,
                  videoPageFromType: VideoPageFromType.tag_detail_relation_list,
                ),
                  binding: BindingsBuilder(() {
                    Get.put(VideoChewiePageController());
                  }),
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
                  Tooltip(
                    message: data.relationDesc ?? "",
                    child: Text(
                      data.relationDesc ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
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
        children: List.generate(controller.mediaList.length, (index) {
          MediaFileData data = controller.mediaList[index];
          return GestureDetector(
            onTap: () {
              Get.to(
                () => VideoChewiePage(
                  videoId: data.id!,
                  videoPath: data.path!,
                  videoPageFromType: VideoPageFromType.tag_detail_video_list,
                ),
                  binding: BindingsBuilder(() {
                Get.put(VideoChewiePageController());
              }),
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
                  Tooltip(
                    message: data.fileName ?? "",
                    child: Text(
                      data.fileName ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTagDetail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller.tagNameController,
          decoration: InputDecoration(labelText: '标签名称'),
        ),
        SizedBox(height: 16.0),
        TextField(
          controller: controller.tagDescController,
          decoration: InputDecoration(labelText: '标签描述'),
        ),
        SizedBox(height: 16.0),
        ElevatedButton.icon(
          onPressed: controller.addImage,
          icon: Icon(Icons.add),
          label: Text('添加图片'),
        ),
        SizedBox(height: 16.0),
        Container(
          height: 200.0,
          child: ListView.builder(
            shrinkWrap: false,
            itemCount: controller.picPath.length,
            itemBuilder: (context, index) {
              final pic = controller.picPath[index];
              return Row(
                children: [
                  Expanded(child: Image.file(File(pic))),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => controller.removeImage(index),
                  ),
                ],
              );
            },
          ),
        ),
        SizedBox(height: 16.0),
        ElevatedButton(
          onPressed: controller.saveChanges,
          child: Text('保存'),
        ),
      ],
    );
  }

  Widget _buildImageWidget(String? imagePath) {
    if (imagePath != null && imagePath.isNotEmpty) {
      List<String> imagePaths = imagePath.split(',');
      return SizedBox(
        child: Image.file(File(imagePaths[0]), fit: BoxFit.contain),
      );
    } else {
      return SizedBox(
        child: Image.asset('assets/image/no-pictures.png', fit: BoxFit.cover),
      );
    }
  }
}

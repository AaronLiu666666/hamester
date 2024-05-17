import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:hamster/media_manage/model/po/media_file_data.dart';
import 'package:hamster/widget/detail_page/relation_detial_page.dart';
import 'package:image_picker/image_picker.dart';

import '../../file/thumbnail_util.dart';
import '../../media_manage/service/media_manager_service.dart';
import '../../relation_manage/relation_manage_service.dart';
import '../../tag_manage/model/po/media_tag_relation.dart';
import '../../tag_manage/model/po/tag_info.dart';
import '../../tag_manage/tag_manage_service.dart';
import '../custom_widget/custom_toggle_button_widget.dart';
import '../video_chewie/video_chewie_page.dart';
import 'media_detail_page.dart';

class GetxTagDetailController extends GetxController {
  TagInfo tagInfo = TagInfo();
  late List<MediaFileData> mediaList;
  late List<MediaTagRelation> relationList;
  late RxList<String> picPath = <String>[].obs;
  late Map<String, MediaFileData> relationMediaMap = {};

  final id = ''.obs;
  final isLoading = true.obs;
  final selectedIndex = 0.obs; // 用于存储选中的列表索引
  final title = "".obs;

  final TextEditingController tagNameController = TextEditingController();
  final TextEditingController tagDescController = TextEditingController();

  RxList<String> levels = <String>[].obs;

  List<MediaFileData> getMediaList() {
    return mediaList;
  }

  List<MediaTagRelation> getRelationList() {
    return relationList;
  }

  Map<String, MediaFileData> getRelationMediaMap() {
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
      tagInfo = await queryDataById(id.value) ?? TagInfo();
      title.value = tagInfo.tagName ?? "";
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
        picPath.value = tagInfo.tagPic!.split(',');
      }
      levels.value = title.value.split('/');
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

  Future<void> loadDataByTagNameLeftLike(String tagName) async {
    try {
      // 设置加载数据 加载动画
      isLoading.value = true;
      List<TagInfo> tagsWithTagName = await queryTagsByTagName(tagName);
      if (tagsWithTagName.isNotEmpty) {
        tagInfo = tagsWithTagName[0];
        id.value = tagInfo.id??"";
      } else {
        tagInfo = TagInfo();
        id.value = '';
      }
      title.value = tagName;

      relationList = await queryRelationsByTagNameLeftLike(tagName);
      final mediaIds = relationList
          .where((relation) => relation.mediaId != null)
          .map((relation) => relation.mediaId!)
          .toSet();
      mediaList = await queryDatasByIds(List.from(mediaIds));
      await generateMediaListThumbnailImages(mediaList);

      final mediaMap = Map.fromIterable(mediaList, key: (e) => e.id);
      // 清空relation map
      relationMediaMap = {};
      for (var relation in relationList) {
        if (relation.mediaId != null) {
          final mediaFileData = mediaMap[relation.mediaId!];
          if (mediaFileData != null) {
            relationMediaMap[relation.id!] = mediaFileData;
          }
        }
      }
      tagNameController.text = tagName;
      tagDescController.text = tagInfo.tagDesc ?? '';
      picPath.value = [];
      if (tagInfo.tagPic != null && tagInfo.tagPic!.isNotEmpty) {
        picPath.value = tagInfo.tagPic!.split(',');
      }
      levels.value = title.value.split('/');
    } catch (e){
      print("切换标签层级失败："+e.toString());
    }finally {
      isLoading.value = false;
    }
  }

  void removeImage(int index) {
    picPath.removeAt(index);
  }

  Future<void> saveChanges() async {
    String needSaveTagName = tagNameController.text;
    if(needSaveTagName==null||needSaveTagName.isEmpty||needSaveTagName.contains("//")){
      Get.snackbar('失败', '标签名不能为空');
      return;
    }
    tagInfo.tagName = tagNameController.text;
    tagInfo.tagDesc = tagDescController.text;
    tagInfo.tagPic = picPath.join(",");
    if(tagInfo==null||tagInfo.id==null||tagInfo.id!.isEmpty){
      await insertOrUpdateTagInfo(tagInfo.tagName!, tagInfo.tagDesc, picPath);
    } else {
      tagInfo.updateTime = DateTime.now().millisecondsSinceEpoch;
      await updateData(tagInfo);
    }
  }

  void deleteTag() async {
    if (id.value.isEmpty) {
      return;
    }
    await deleteTagAndRelation(id.value);
  }

  void onTagLevelClicked(int level) {
    if (level < levels.length) {
      String tagName = levels.sublist(0, level + 1).join('/');
      loadDataByTagNameLeftLike(tagName); // 重新加载数据
    }
  }
}

class GetxTagDetailPage extends GetView<GetxTagDetailController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          // () => Text('标签详情: ${controller.title ?? ""}'),
          () => _buildBreadcrumbs(),
        ),
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
                      _buildTagDetail(context),
                  ],
                ),
              ),
      ),
    );
  }

  // 如果既不想水平滚动也不想省略显示，可以考虑使用换行的方式来显示长标签路径。我们可以利用 Wrap 小部件来实现这个功能，这样当一行显示不下时，就会自动换行。
  // Widget _buildBreadcrumbs() {
  //   List<String> levels = controller.levels;
  //   List<Widget> breadcrumbs = [];
  //   for (int i = 0; i < levels.length; i++) {
  //     breadcrumbs.add(InkWell(
  //       onTap: () => controller.onTagLevelClicked(i),
  //       child: Text(
  //         levels[i],
  //         style: TextStyle(
  //           color: Colors.blue,
  //           decoration: TextDecoration.underline,
  //         ),
  //       ),
  //     ));
  //     if (i < levels.length - 1) {
  //       breadcrumbs.add(Text(' / '));
  //     }
  //   }
  //   return Wrap(
  //     children: breadcrumbs,
  //   );
  // }
  Widget _buildBreadcrumbs() {
    List<String> levels = controller.levels;
    List<Widget> breadcrumbs = [];
    for (int i = 0; i < levels.length; i++) {
      breadcrumbs.add(InkWell(
        onTap: () => controller.onTagLevelClicked(i),
        child: Text(
          levels[i],
          style: TextStyle(
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
        ),
      ));
      if (i < levels.length - 1) {
        breadcrumbs.add(Text(' / '));
      }
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: breadcrumbs,
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
                  Get.put(VideoChewiePageController(
                    videoId: controller.relationMediaMap[data.id!]!.id!,
                    videoPath: controller.relationMediaMap[data.id!]!.path!,
                    seekTo: data.mediaMoment,
                    videoPageFromType:
                        VideoPageFromType.tag_detail_relation_list,
                  ));
                }),
              );
            },
            onLongPress: () {
              Get.to(() => GetxRelationDetailPage(),
                  binding: BindingsBuilder(() {
                Get.put(GetxRelationDetailPageController(
                    id: controller.relationList[index].id ?? ""));
              }));
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
                  Get.put(VideoChewiePageController(
                    videoId: data.id!,
                    videoPath: data.path!,
                    videoPageFromType: VideoPageFromType.tag_detail_video_list,
                  ));
                }),
              );
            },
            onLongPress: () {
              Get.to(() => MediaDetailPage(), binding: BindingsBuilder(() {
                Get.put(MediaDetailPageController(
                    mediaId: controller.mediaList[index].id ?? 0));
              }));
            },
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

  Widget _buildTagDetail(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller.tagNameController,
            decoration: InputDecoration(labelText: '标签名称'),
            onChanged: (value) {
              controller.title.value = value;
            },
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
          Center(
            child: ElevatedButton(
              onPressed: controller.saveChanges,
              child: Text('保存'),
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("确认删除"),
                      actions: <Widget>[
                        TextButton(
                          child: Text("取消"),
                          onPressed: () {
                            Navigator.of(context).pop(); // 关闭对话框
                          },
                        ),
                        TextButton(
                          child: Text("确定"),
                          onPressed: () {
                            // 在这里添加删除操作的逻辑
                            controller.deleteTag();
                            Navigator.of(context).pop(); // 关闭对话框
                            Navigator.of(context).pop(); // 从详情页面返回
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text("删除"),
            ),
          )
        ],
      ),
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

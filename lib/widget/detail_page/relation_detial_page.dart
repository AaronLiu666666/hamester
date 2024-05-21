import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:hamster/media_manage/model/po/media_file_data.dart';
import 'package:hamster/tag_manage/model/po/media_tag_relation.dart';
import 'package:hamster/tag_manage/model/po/tag_info.dart';

import '../../media_manage/service/media_manager_service.dart';
import '../../relation_manage/relation_manage_service.dart';
import '../../tag_manage/tag_manage_service.dart';
import 'media_detail_page.dart';
import 'tag_detail_page.dart';
import '../video_chewie/video_chewie_page.dart';

/// 关联详情页面
class GetxRelationDetailPage extends GetView<GetxRelationDetailPageController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Obx(
            () => Text('关联详情: ${controller.title ?? ""}'),
          ),
        ),
        body: Obx(() => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          child: Image.file(
                            File(controller.relation.mediaMomentPic!),
                            fit: BoxFit.contain,
                          ),
                          onTap: () {
                            Get.to(
                              () => VideoChewiePage(
                                videoId: controller.media.id!,
                                videoPath: controller.media.path!,
                                seekTo: controller.relation.mediaMoment,
                                videoPageFromType: VideoPageFromType.relation_detial_page,
                              ),
                              binding: BindingsBuilder(() {
                                Get.put(VideoChewiePageController(
                                  videoId: controller.media.id!,
                                  videoPath: controller.media.path!,
                                  seekTo: controller.relation.mediaMoment,
                                  videoPageFromType: VideoPageFromType.relation_detial_page,
                                ));
                              }),
                            );
                          },
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: controller.descriptionController,
                          decoration: InputDecoration(labelText: '描述'),
                          maxLines: null,
                        ),
                        SizedBox(height: 16),
                        Text("创建时间：${DateTime.fromMillisecondsSinceEpoch(controller.relation.createTime??0).toString().split('.')[0]}"??""),
                        SizedBox(height: 16),
                        Text(
                          '标签:',
                          style: TextStyle(fontSize: 18),
                        ),
                        GestureDetector(
                          onTap: () {
                            Get.to(() => GetxTagDetailPage(), arguments: controller.tagInfo.id,
                                binding: BindingsBuilder(() {
                                  Get.put(GetxTagDetailController());
                                }));
                          },
                          child: Chip(label: Text(controller.tagInfo.tagName ?? '')),
                        ),
                        GestureDetector(
                          onTap: () {
                            Get.to(
                              () => VideoChewiePage(
                                videoId: controller.media.id!,
                                videoPath: controller.media.path!,
                                videoPageFromType: VideoPageFromType.relation_detial_page,
                              ),
                              binding: BindingsBuilder(() {
                                Get.put(VideoChewiePageController(
                                  videoId: controller.media.id!,
                                  videoPath: controller.media.path!,
                                  videoPageFromType: VideoPageFromType.relation_detial_page,
                                ));
                              }),
                            );
                          },
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.file(
                                    File(controller.media.cover!),
                                    fit: BoxFit.contain,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    controller.media.fileName ?? '',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          onLongPress: (){
                            Get.to(() => MediaDetailPage(),
                                binding: BindingsBuilder(() {
                                  Get.put(MediaDetailPageController(mediaId:controller.media.id??0));
                                }));
                          },
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        controller.saveDescription();
                      },
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
                                    controller.deleteRelation();
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
              )));
  }
}

class GetxRelationDetailPageController extends GetxController {
  final String id;

  late MediaTagRelation relation;

  late TagInfo tagInfo;

  late MediaFileData media;

  late TextEditingController descriptionController = TextEditingController();

  RxString descText = ''.obs;

  RxString title = ''.obs;

  // 加载状态
  RxBool isLoading = true.obs;

  GetxRelationDetailPageController({required this.id});

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  // 加载数据
  Future<void> loadData() async {
    try {
      MediaTagRelation? relationFromDB = await queryRelationById(id);
      String? tagId = relationFromDB!.tagId;
      int? mediaId = relationFromDB!.mediaId;
      TagInfo? tag = await queryDataById(tagId!);
      MediaFileData? mediaFromDB = await queryMediaDataById(mediaId!);
      relation = relationFromDB;
      tagInfo = tag!;
      media = mediaFromDB!;
      descriptionController.text = relation.relationDesc ?? '';
      if (null != relation.relationDesc && relation.relationDesc!.isNotEmpty) {
        title.value = relation.relationDesc!;
      } else {
        title.value = tagInfo.tagName ?? "";
      }
    } finally {
      isLoading.value = false; // 加载完成后设置为false
    }
  }

  void saveDescription() async {
    relation.relationDesc = descriptionController.text;
    await updateRelation(relation);
  }

  void deleteRelation() async {
    await deleteRelationById(id);
  }
}

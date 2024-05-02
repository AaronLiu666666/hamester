import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:hamster/media_manage/model/po/media_file_data.dart';
import 'package:hamster/tag_manage/model/po/media_tag_relation.dart';
import 'package:hamster/tag_manage/model/po/tag_info.dart';
import 'package:hamster/widget/list_page/tag_detail_page.dart';
import 'package:video_player/video_player.dart';

import '../../media_manage/service/media_manager_service.dart';
import '../../relation_manage/relation_manage_service.dart';
import '../../tag_manage/tag_manage_service.dart';
import '../list_page/getx_tag_detail_page.dart';
import '../video_chewie/video_chewie_page.dart';

/// 媒体详情页面 长按媒体列表某条数据进入
/// 可以添加别名 alias 备注信息 memo
/// 查看标签 关联关系
class MediaDetailPage extends GetView<MediaDetailPageController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('视频详情:'),
      ),
      body: Obx(
        () => controller.isLoading.value
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 封面展示
                    // 图片展示
                    if (controller.mediaFileData.cover != null)
                      Container(
                        height: 200, // 设置高度为200
                        child: Image.file(
                          File(controller.mediaFileData.cover!),
                          fit: BoxFit.fill,
                        ),
                      ),
                    Text(
                      '文件名: ${controller.mediaFileData.fileName ?? ""}',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '文件时长: ${controller.videoLength.value}',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '创建时间: ${(controller.mediaFileData.createTimeAsDateTime?.toString() ?? "").split('.')[0]}',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '文件别名:',
                      style: TextStyle(fontSize: 18),
                    ),
                    TextFormField(
                      controller: controller.aliasTextEditingController,
                      decoration: InputDecoration(
                        hintText: '输入文件别名...',
                      ),
                      onChanged: (value) {
                        controller.updateAliasText(value);
                      },
                    ),
                    SizedBox(height: 10),
                    Text(
                      '描述:',
                      style: TextStyle(fontSize: 18),
                    ),
                    TextFormField(
                      controller: controller.descTextEditingController,
                      decoration: InputDecoration(
                        hintText: '输入描述...',
                      ),
                      onChanged: (value) {
                        controller.updateDescText(value);
                      },
                    ),
                    SizedBox(height: 10),

                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          controller.updateThisMediaFileData();
                        },
                        child: Text('保存'),
                      ),
                    ),
                    Text(
                      '标签:',
                      style: TextStyle(fontSize: 18),
                    ),
                    Wrap(
                      spacing: 8,
                      children: controller.tagList.map((tag) {
                        return GestureDetector(
                          onTap: () {
                            Get.to(() => GetxTagDetailPage(), arguments: tag.id!,
                                binding: BindingsBuilder(() {
                                  Get.put(GetxTagDetailController());
                                }));
                          },
                          child: Chip(label: Text(tag.tagName ?? '')),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20),
                    Text(
                      '关联列表:',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 10),
                    // 关联列表
                    SizedBox(
                      height: 800,
                      child: GridView.count(
                        crossAxisCount: 2,
                        children: List.generate(controller.relationList.length, (index) {
                          MediaTagRelation data = controller.relationList[index];
                          return GestureDetector(
                            onTap: () {
                              Get.to(
                                    () => VideoChewiePage(
                                  videoId: data.mediaId??0,
                                  videoPath: data.mediaPath??"",
                                  seekTo: data.mediaMoment,
                                  videoPageFromType: VideoPageFromType.media_detail_page,
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
                    )
                  ],
                ),
              ),
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

class MediaDetailPageController extends GetxController {
  final int mediaId;
  MediaFileData mediaFileData = MediaFileData();
  late List<MediaTagRelation> relationList;
  late List<TagInfo> tagList;
  final TextEditingController aliasTextEditingController = TextEditingController();
  final TextEditingController descTextEditingController = TextEditingController();
  RxString aliasText = ''.obs;
  RxString descText = ''.obs;

  // yyyy-MM-dd HH:mm:ss
  RxString videoLength = "".obs;
  final isLoading = true.obs;

  MediaDetailPageController({required this.mediaId});


  @override
  void dispose() {
    aliasTextEditingController.dispose();
    descTextEditingController.dispose();
    super.dispose();
  }

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    try {
      mediaFileData = await queryMediaDataById(mediaId) ?? MediaFileData();
      aliasTextEditingController.text = mediaFileData.fileAlias??"";
      aliasText.value = mediaFileData.fileAlias??"";
      descTextEditingController.text = mediaFileData.memo??"";
      descText.value = mediaFileData.memo??"";
      relationList = await queryRelationsByMediaId(mediaId);
      tagList = await queryTagsByMediaId(mediaId);
      VideoPlayerController controller =
          VideoPlayerController.file(File(mediaFileData.path ?? ''));
      await controller.initialize();
      Duration videoLengthDuration = controller.value.duration;

      String hoursString =
          videoLengthDuration.inHours.toString().padLeft(2, '0');
      String minutesString =
          (videoLengthDuration.inMinutes % 60).toString().padLeft(2, '0');
      String secondsString =
          (videoLengthDuration.inSeconds % 60).toString().padLeft(2, '0');
      videoLength.value = '$hoursString:$minutesString:$secondsString';
      controller.dispose();
    } finally {
      isLoading.value = false;
    }
  }

  List<MediaTagRelation> getRelationList() {
    return relationList;
  }

  void updateAliasText(String value) {
    aliasTextEditingController.text=value;
    aliasText.value = value;
  }

  void updateDescText(String value) {
    descTextEditingController.text=value;
    descText.value = value;
  }

  void updateThisMediaFileData() {
    bool needUpdate = false;
    if(aliasText.value!=mediaFileData.fileAlias){
      mediaFileData.fileAlias = aliasText.value;
      needUpdate = true;
    }
    if(descText.value!= mediaFileData.memo){
      mediaFileData.memo = descText.value;
      needUpdate = true;
    }
    if(needUpdate){
      updateMediaFileData(mediaFileData);
    }
  }
}

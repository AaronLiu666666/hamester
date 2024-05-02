import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hamster/widget/list_page/page_util/page_util.dart';
import 'package:hamster/widget/video_chewie/video_chewie_page.dart';

import '../../file/thumbnail_util.dart';
import '../../media_manage/model/po/media_file_data.dart';
import '../../media_manage/service/media_manager_service.dart';
import '../../relation_manage/relation_manage_service.dart';
import '../../tag_manage/model/dto/search_dto.dart';
import '../../tag_manage/model/po/media_tag_relation.dart';
import '../list_page/getx_tag_detail_page.dart';
import '../list_page/media_home_page.dart';

class VideoDTO {
  int id;
  String path;
  int? seekTo;
  String? cover;

  VideoDTO({required this.id, required this.path, this.seekTo, this.cover});
}

class VideoHorizontalScrollWidget extends StatelessWidget {
  VideoHorizontalScrollWidget({Key? key}) : super(key: key) {}

  @override
  Widget build(BuildContext context) {
    return GetBuilder<VideoHorizontalScrollPagingController>(
      builder: (controller) {
        return buildCustomRefreshListWidget<VideoDTO,
            VideoHorizontalScrollPagingController>(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          listEnum: ListEnum.list,
          enablePullDown: true,
          enablePullUp: true,
          physics: AlwaysScrollableScrollPhysics(),
          onItemClick: (data, index) {
            Get.find<VideoChewiePageController>().switchVideo(
                videoId: data.id ?? 0,
                videoPath: data.path ?? "",
                seekTo: data.seekTo);
          },
          itemBuilder: (data, index) => Padding(
            padding: EdgeInsets.symmetric(horizontal: 2),
            child: Card(
              color: Colors.white.withOpacity(0.3),
              child: SizedBox(
                height: 70,
                width: 80,
                child: Image.file(
                  File(data.cover ?? ""),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class VideoHorizontalScrollPagingController
    extends PagingController<VideoDTO, PagingState<VideoDTO>> {
  @override
  Future<PagingData<VideoDTO>?> loadData(PagingParams pagingParams) async {
    VideoChewiePageController videoChewiePageController =
        Get.find<VideoChewiePageController>();
    VideoPageFromType videoPageFromType =
        videoChewiePageController.getVideoPageFromType();

    if (videoPageFromType == VideoPageFromType.media_page) {
      return loadDataFromMediaPage(pagingParams);
    }

    if (videoPageFromType == VideoPageFromType.tag_detail_relation_list) {
      return loadDataFromTagDetailRelationList(pagingParams);
    }

    if (videoPageFromType == VideoPageFromType.tag_detail_video_list) {
      return loadDataFromTagDetailVideoList(pagingParams);
    }

    if (videoPageFromType == VideoPageFromType.relation_page) {
      return loadDataFromRelationPage(pagingParams);
    }

    if(videoPageFromType == VideoPageFromType.tag_page){
      return loadDataFromTagPage(pagingParams);
    }
  }

  Future<PagingData<VideoDTO>?> loadDataFromTagPage(
      PagingParams pagingParams) async {
    VideoChewiePageController videoChewiePageController =
    Get.find<VideoChewiePageController>();
    String tagId = videoChewiePageController.getTagId();
    List<MediaTagRelation> relationList = await queryRelationsByTagIdWithMediaPath(tagId);
    List<VideoDTO> videoDTOList = List.empty(growable: true);
    for (var relation in relationList) {
      VideoDTO videoDTO = VideoDTO(
          id: relation.mediaId!,
          path: relation.mediaPath!,
          cover: relation.mediaMomentPic,
          seekTo: relation.mediaMoment);
      videoDTOList.add(videoDTO);
    }
    return PagingData<VideoDTO>()
      ..current = 1
      ..pages = 1
      ..data = videoDTOList
      ..size = videoDTOList.length // 设置每页数据量
      ..total = videoDTOList.length;
  }

  Future<PagingData<VideoDTO>?> loadDataFromRelationPage(
      PagingParams pagingParams) async {
    CustomSearchController searchController =
        Get.find<CustomSearchController>();
    // 刷新数据
    SearchDTO homepageSearchDTO = searchController.getSearchDTO();
    SearchDTO searchDTO = SearchDTO(
      page: pagingParams.current,
      pageSize: pagingParams.size,
      content: homepageSearchDTO.content,
    );
    int total = await searchRelationCount(searchDTO);
    final List<MediaTagRelation> list = await searchRelationPage(searchDTO);
    int pages = (total / pagingParams.size).ceil();
    List<VideoDTO> videoDTOList = List.empty(growable: true);
    for (var mediaTagRelation in list) {
      VideoDTO videoDTO = VideoDTO(
          id: mediaTagRelation.mediaId!,
          path: mediaTagRelation.mediaPath??"",
          seekTo: mediaTagRelation.mediaMoment,
          cover: mediaTagRelation.mediaMomentPic);
      videoDTOList.add(videoDTO);
    }
    return PagingData<VideoDTO>()
      ..current = pagingParams.current
      ..pages = pages
      ..data = videoDTOList
      ..size = pagingParams.size // 设置每页数据量
      ..total = total;
  }

  Future<PagingData<VideoDTO>?> loadDataFromTagDetailRelationList(
      PagingParams pagingParams) async {
    GetxTagDetailController getxTagDetailController =
        Get.find<GetxTagDetailController>();
    List<MediaTagRelation> relationList =
        getxTagDetailController.getRelationList();
    Map<String, MediaFileData> relationMediaMap =
        getxTagDetailController.getRelationMediaMap();
    List<VideoDTO> videoDTOList = List.empty(growable: true);
    for (var relation in relationList) {
      MediaFileData mediaFileData =
          relationMediaMap[relation.id!] ?? MediaFileData();
      VideoDTO videoDTO = VideoDTO(
          id: mediaFileData.id!,
          path: mediaFileData.path!,
          cover: relation.mediaMomentPic,
          seekTo: relation.mediaMoment);
      videoDTOList.add(videoDTO);
    }
    return PagingData<VideoDTO>()
      ..current = 1
      ..pages = 1
      ..data = videoDTOList
      ..size = videoDTOList.length // 设置每页数据量
      ..total = videoDTOList.length;
  }

  Future<PagingData<VideoDTO>?> loadDataFromTagDetailVideoList(
      PagingParams pagingParams) async {
    GetxTagDetailController getxTagDetailController =
        Get.find<GetxTagDetailController>();
    List<MediaFileData> mediaList = getxTagDetailController.getMediaList();
    List<VideoDTO> videoDTOList = List.empty(growable: true);
    for (var media in mediaList) {
      VideoDTO videoDTO =
          VideoDTO(id: media.id!, path: media.path!, cover: media.cover);
      videoDTOList.add(videoDTO);
    }
    return PagingData<VideoDTO>()
      ..current = 1
      ..pages = 1
      ..data = videoDTOList
      ..size = videoDTOList.length // 设置每页数据量
      ..total = videoDTOList.length;
  }

  Future<PagingData<VideoDTO>?> loadDataFromMediaPage(
      PagingParams pagingParams) async {
    CustomSearchController searchController =
        Get.find<CustomSearchController>();
    // 刷新数据
    SearchDTO homepageSearchDTO = searchController.getSearchDTO();
    SearchDTO searchDTO =
        SearchDTO(page: pagingParams.current, pageSize: pagingParams.size);
    searchDTO.content = homepageSearchDTO.content;
    int total = await searchMediaCount(searchDTO);
    final List<MediaFileData> list = await searchMediaPage(searchDTO);
    List<VideoDTO> videoDTOList = List.empty(growable: true);
    for (var mediaFileData in list) {
      VideoDTO videoDTO = VideoDTO(
          id: mediaFileData.id!,
          path: mediaFileData.path!,
          cover: mediaFileData.cover);
      videoDTOList.add(videoDTO);
    }
    // 为没有生成缩略图的视频添加缩略图
    generateMediaListThumbnailImages(list);
    int pages = (total / pagingParams.size).ceil();
    return PagingData<VideoDTO>()
      ..current = pagingParams.current
      ..pages = pages
      ..data = videoDTOList
      ..size = pagingParams.size // 设置每页数据量
      ..total = total;
  }

  @override
  PagingState<VideoDTO> getState() {
    return PagingState<VideoDTO>()..refreshId = this;
  }

  @override
  Future<void> initBeforeLoadData() async {
    VideoChewiePageController videoChewiePageController =
        Get.find<VideoChewiePageController>();
    VideoPageFromType videoPageFromType =
        videoChewiePageController.getVideoPageFromType();
    if (videoPageFromType == VideoPageFromType.media_page) {
      // 下拉刷新的时候调用的方法，下拉刷新时会重新扫描媒体文件列表
      MediaManageService mediaManageService = MediaManageService();
      await mediaManageService.initMediaFileData();
    }
  }
}

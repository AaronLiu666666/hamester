import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../media_manage/service/media_manager_service.dart';

/// 分页状态数据
class PagingState<T> {
  /// 分页的页数
  int pageIndex = 1;

  ///是否还有更多数据
  bool hasMore = true;

  /// 用于列表刷新的id
  Object refreshId = Object();

  /// 列表数据
  List<T> data = <T>[];
}

abstract class PagingController<M, S extends PagingState<M>>
    extends GetxController {
  /// PagingState
  late S pagingState;

  /// 刷新控件的 Controller
  RefreshController refreshController = RefreshController();

  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_sendScrollNotification);
    /// 保存 State
    pagingState = getState();
  }


  @override
  void onClose() {
    scrollController.removeListener(_sendScrollNotification);
    super.onClose();
  }

  // 主要为了视频播放页面 VideoChewiePage 在滑动横向列表时，通知VideoChewiePage将控制横线滚动列表显示隐藏的计时器进行重新计时
  void _sendScrollNotification() {
    final scrollOffset = scrollController.offset;
    CustomScrollNotification(scrollOffset).dispatch(Get.context!);
  }

  @override
  void onReady() {
    super.onReady();

    /// 进入页面刷新数据
    refreshData();
  }

  /// 刷新数据
  void refreshData() async {
    initPaging();
    await initBeforeLoadData();
    await _loadData();

    /// 刷新完成
    refreshController.refreshCompleted();
  }

  void refreshDataNotScan() async {
    initPaging();
    await _loadData();

    /// 刷新完成
    refreshController.refreshCompleted();
  }

  ///初始化分页数据
  void initPaging() {
    pagingState.pageIndex = 1;
    pagingState.hasMore = true;
    pagingState.data.clear();
  }

  /// 数据加载
  Future<List<M>?> _loadData() async {
    PagingParams pagingParams =
        PagingParams.create(pageIndex: pagingState.pageIndex);
    PagingData<M>? pagingData = await loadData(pagingParams);
    List<M>? list = pagingData?.data;

    /// 数据不为空，则将数据添加到 data 中
    /// 并且分页页数 pageIndex + 1
    if (list != null && list.isNotEmpty) {
      pagingState.data.addAll(list);
      pagingState.pageIndex += 1;
    }

    /// 判断是否有更多数据
    pagingState.hasMore = pagingState.data.length < (pagingData?.total ?? 0);

    /// 更新界面
    update([pagingState.refreshId]);
    return list;
  }

  /// 加载更多
  void loadMoreData() async {
    await _loadData();

    /// 加载完成
    refreshController.loadComplete();
  }

  /// 最终加载数据的方法
  Future<PagingData<M>?> loadData(PagingParams pagingParams);

  /// 获取 State
  S getState();

  Future<void> initBeforeLoadData();
}

class PagingParams {
  int current = 1;
  Map<String, dynamic>? extra = {};
  Map<String, dynamic> model = {};
  String? order = 'descending';
  int size = 15;
  String? sort = "id";

  factory PagingParams.create({required int pageIndex}) {
    var params = PagingParams();
    params.current = pageIndex;
    return params;
  }

  PagingParams();
}

class PagingData<T> {
  int? current;
  int? pages;
  List<T>? data;
  int? size;
  int? total;

  PagingData();
}

Widget buildListView<T>(
    {required Widget Function(T item, int index) itemBuilder,
    required List<T> data,
    Widget Function(T item, int index)? separatorBuilder,
    Function(T item, int index)? onItemClick,
    ScrollPhysics? physics,
    bool shrinkWrap = false,
    Axis scrollDirection = Axis.vertical}) {
  return GridView.builder(
    shrinkWrap: shrinkWrap,
    physics: physics,
    padding: EdgeInsets.zero,
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      mainAxisSpacing: 0, // 主轴（垂直）间距
      crossAxisSpacing: 0,
      // 交叉轴（水平）间距
    ),
    itemCount: data.length,
    itemBuilder: (ctx, index) {
      return GestureDetector(
        onTap: () => onItemClick?.call(data[index], index),
        child: itemBuilder(data[index], index),
      );
    },
  );
}

Widget buildRefreshWidget({
  required Widget Function() builder,
  VoidCallback? onRefresh,
  VoidCallback? onLoad,
  required RefreshController refreshController,
  bool enablePullUp = true,
  bool enablePullDown = true,
  Axis scrollDirection = Axis.vertical,
}) {
  return SmartRefresher(
    enablePullUp: enablePullUp,
    enablePullDown: enablePullDown,
    controller: refreshController,
    onRefresh: onRefresh,
    onLoading: onLoad,
    header: ClassicHeader(
      // idleText: "下拉刷新",
      // releaseText: "松开刷新",
      // completeText: "刷新完成",
      // refreshingText: "加载中......",
      idleText: "",
      releaseText: "",
      completeText: "",
      refreshingText: "",
      idleIcon: scrollDirection == Axis.horizontal
          ? const Icon(Icons.arrow_right, color: Colors.grey)
          : const Icon(Icons.arrow_downward, color: Colors.grey),
    ),
    footer:  ClassicFooter(
      // idleText: "上拉加载更多",
      // canLoadingText: "松开加载更多",
      // loadingText: "加载中......",
      idleText: "",
      canLoadingText: "",
      loadingText: "",
      idleIcon: scrollDirection == Axis.horizontal
          ? const Icon(Icons.arrow_left, color: Colors.grey)
          : const Icon(Icons.arrow_upward, color: Colors.grey),
    ),
    child: builder(),
  );
}

Widget buildRefreshListWidget<T, C extends PagingController<T, PagingState<T>>>(
    {required Widget Function(T item, int index) itemBuilder,
    bool enablePullUp = true,
    bool enablePullDown = true,
    String? tag,
    Widget Function(T item, int index)? separatorBuilder,
    Function(T item, int index)? onItemClick,
    ScrollPhysics? physics,
    bool shrinkWrap = false,
    Axis scrollDirection = Axis.vertical}) {
  C controller = Get.find(tag: tag);
  return GetBuilder<C>(
    builder: (controller) {
      return buildRefreshWidget(
        builder: () => buildListView<T>(
            data: controller.pagingState.data,
            separatorBuilder: separatorBuilder,
            itemBuilder: itemBuilder,
            onItemClick: onItemClick,
            physics: physics,
            shrinkWrap: shrinkWrap,
            scrollDirection: scrollDirection),
        refreshController: controller.refreshController,
        onRefresh: controller.refreshData,
        onLoad: controller.loadMoreData,
        enablePullDown: enablePullDown,
        enablePullUp: enablePullUp && controller.pagingState.hasMore,
      );
    },
    tag: tag,
    id: controller.pagingState.refreshId,
  );
}

// Widget buildCustomRefreshListWidget<T, C extends PagingController<T, PagingState<T>>>({
//   required Widget Function(T item, int index) itemBuilder,
//   bool enablePullUp = true,
//   bool enablePullDown = true,
//   String? tag,
//   Widget Function(T item, int index)? separatorBuilder,
//   Function(T item, int index)? onItemClick,
//   ScrollPhysics? physics,
//   bool shrinkWrap = false,
//   Axis scrollDirection = Axis.vertical,
//   ListEnum listEnum = ListEnum.grid,
// }) {
//   C controller = Get.find(tag: tag);
//   return Obx(
//         () => buildRefreshWidget(
//       builder: () => buildCustomListView<T>(
//         data: controller.pagingState.data,
//         separatorBuilder: separatorBuilder,
//         itemBuilder: itemBuilder,
//         onItemClick: onItemClick,
//         physics: physics,
//         shrinkWrap: shrinkWrap,
//         scrollDirection: scrollDirection,
//         listEnum: listEnum,
//       ),
//       refreshController: controller.refreshController,
//       onRefresh: controller.refreshData,
//       onLoad: controller.loadMoreData,
//       enablePullDown: enablePullDown,
//       enablePullUp: enablePullUp && controller.pagingState.hasMore,
//     ),
//   );
// }
Widget buildCustomRefreshListWidget<T,
    C extends PagingController<T, PagingState<T>>>({
  required Widget Function(T item, int index) itemBuilder,
  bool enablePullUp = true,
  bool enablePullDown = true,
  String? tag,
  Widget Function(T item, int index)? separatorBuilder,
  Function(T item, int index)? onItemClick,
  ScrollPhysics? physics,
  bool shrinkWrap = false,
  Axis scrollDirection = Axis.vertical,
  ListEnum listEnum = ListEnum.grid,
}) {
  C controller = Get.find(tag: tag);
  return GetBuilder<C>(
    builder: (controller) {
      return buildRefreshWidget(
        builder: () => buildCustomListView<T>(
            data: controller.pagingState.data,
            separatorBuilder: separatorBuilder,
            itemBuilder: itemBuilder,
            onItemClick: onItemClick,
            physics: physics,
            shrinkWrap: shrinkWrap,
            scrollDirection: scrollDirection,
            listEnum: listEnum),
        scrollDirection: scrollDirection,
        refreshController: controller.refreshController,
        onRefresh: controller.refreshData,
        onLoad: controller.loadMoreData,
        enablePullDown: enablePullDown,
        enablePullUp: enablePullUp && controller.pagingState.hasMore,
      );
    },
    tag: tag,
    id: controller.pagingState.refreshId,
  );
}

Widget buildCustomListView<T>(
    {required Widget Function(T item, int index) itemBuilder,
    required List<T> data,
    Widget Function(T item, int index)? separatorBuilder,
    Function(T item, int index)? onItemClick,
    ScrollPhysics? physics,
    bool shrinkWrap = false,
    Axis scrollDirection = Axis.vertical,
    ListEnum listEnum = ListEnum.grid}) {
  if (listEnum == ListEnum.list) {
    // return Container(
    //   height: 100,
    //   padding: EdgeInsets.all(2),
    //   width: double.maxFinite,
    //   child:
    return ListView.builder(
      physics:physics,
      scrollDirection: scrollDirection,
      shrinkWrap: shrinkWrap,
      itemCount: data.length, // 指定列表项的数量
      itemBuilder: (ctx, index) {
        return GestureDetector(
          onTap: () => onItemClick?.call(data[index], index),
          child: itemBuilder(data[index], index),
        );
      },
    );
    // );
  }

  return GridView.builder(
    shrinkWrap: shrinkWrap,
    physics: physics,
    padding: EdgeInsets.zero,
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      mainAxisSpacing: 0, // 主轴（垂直）间距
      crossAxisSpacing: 0,
      // 交叉轴（水平）间距
    ),
    itemCount: data.length,
    itemBuilder: (ctx, index) {
      return GestureDetector(
        onTap: () => onItemClick?.call(data[index], index),
        child: itemBuilder(data[index], index),
      );
    },
  );
}

enum ListEnum { grid, list }

class CustomScrollNotification extends Notification {
  final double scrollOffset;

  CustomScrollNotification(this.scrollOffset);
}
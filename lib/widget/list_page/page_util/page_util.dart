import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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

  /// 总记录数
  int totalCount = 0;

  int pageSize = 15;

  /// 总页数
  int totalPages = 0;
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
    // await _loadMoreData();
    await _loadPageData();

    /// 刷新完成
    refreshController.refreshCompleted();
  }

  void refreshDataNotScan() async {
    initPaging();
    await _loadPageData();

    /// 刷新完成
    refreshController.refreshCompleted();
  }

  ///初始化分页数据
  void initPaging() {
    pagingState.pageIndex = 1;
    pagingState.hasMore = true;
    pagingState.data.clear();
  }

  Future<void> pageNavigate() async {
    pagingState.hasMore = pagingState.pageSize < pagingState.totalPages;
    pagingState.data.clear();
    await _loadPageAndBeforeData();
  }

  Future scrollToBottom() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });
  }
  Future scrollToTop() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.jumpTo(0.0);
    });
  }

  Future scrollToBottom2() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });
  }

  Future<void> pageAdd() async {
    print("向下翻页：当前页 ${pagingState.pageIndex}");
    if (pagingState.hasMore && pagingState.pageIndex < pagingState.totalPages) {
      pagingState.pageIndex++;
      await pageNavigate();
      await scrollToBottom();
    }
    print("向下翻页：结果页 ${pagingState.pageIndex}");
  }

  Future<void> pageSub() async {
    print("向上翻页：当前页 " + pagingState.pageIndex.toString());
    if (pagingState.pageIndex > 1) {
      pagingState.pageIndex--;
      await pageNavigate();
      await scrollToBottom();
      print("向上翻页：结果页 " + pagingState.pageIndex.toString());
    }
  }

  /// 数据加载
  Future<List<M>?> _loadMoreData() async {
    PagingParams pagingParams =
        PagingParams.create(pageIndex: pagingState.pageIndex + 1);
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
    pagingState.totalCount = pagingData?.total ?? 0;
    pagingState.totalPages = pagingData?.pages ?? 0;

    /// 更新界面
    update([pagingState.refreshId]);
    return list;
  }

  Future<List<M>?> _loadPageData() async {
    PagingParams pagingParams =
        PagingParams.create(pageIndex: pagingState.pageIndex);
    PagingData<M>? pagingData = await loadData(pagingParams);
    List<M>? list = pagingData?.data;

    /// 数据不为空，则将数据添加到 data 中
    /// 并且分页页数 pageIndex + 1
    if (list != null && list.isNotEmpty) {
      pagingState.data.addAll(list);
    }

    /// 判断是否有更多数据
    pagingState.hasMore = pagingState.data.length < (pagingData?.total ?? 0);
    pagingState.totalCount = pagingData?.total ?? 0;
    pagingState.totalPages = pagingData?.pages ?? 0;

    /// 更新界面
    update([pagingState.refreshId]);
    return list;
  }


  Future<List<M>?> _loadPageAndBeforeData() async {
    PagingParams pagingParams =
    PagingParams.create(pageIndex: 1);
    int num = pagingState.pageIndex * pagingState.pageSize;
    pagingParams.size = num;
    PagingData<M>? pagingData = await loadData(pagingParams);
    List<M>? list = pagingData?.data;

    /// 数据不为空，则将数据添加到 data 中
    /// 并且分页页数 pageIndex + 1
    if (list != null && list.isNotEmpty) {
      pagingState.data.addAll(list);
    }

    /// 判断是否有更多数据
    pagingState.hasMore = pagingState.data.length < (pagingData?.total ?? 0);
    pagingState.totalCount = pagingData?.total ?? 0;
    pagingState.totalPages = ((pagingData?.total??0)/15).ceil();

    /// 更新界面
    update([pagingState.refreshId]);
    return list;
  }

  /// 加载更多
  void loadMoreData() async {
    await _loadMoreData();

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
    Axis scrollDirection = Axis.vertical,
    required ScrollController scrollController}) {
  return GridView.builder(
    controller: scrollController,
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

Widget buildRefreshWidget<T, C extends PagingController<T, PagingState<T>>>({
  required Widget Function() builder,
  VoidCallback? onRefresh,
  VoidCallback? onLoad,
  required RefreshController refreshController,
  bool enablePullUp = true,
  bool enablePullDown = true,
  Axis scrollDirection = Axis.vertical,
  bool showPageBar = false,
  required C controller,
  required ScrollController scrollController,
}) {
  if (showPageBar) {
    return Column(
      children: [
        Expanded(
          child: SmartRefresher(
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
            footer: ClassicFooter(
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
          ),
        ),
        buildPageNavigationBar(controller),
      ],
    );
  }

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
    footer: ClassicFooter(
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
    scrollController:scrollController,
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
      return buildRefreshWidget<T, PagingController<T, PagingState<T>>>(
        builder: () => buildListView<T>(
            data: controller.pagingState.data,
            separatorBuilder: separatorBuilder,
            itemBuilder: itemBuilder,
            onItemClick: onItemClick,
            physics: physics,
            shrinkWrap: shrinkWrap,
            scrollDirection: scrollDirection,
        scrollController: controller.scrollController),
        refreshController: controller.refreshController,
        onRefresh: controller.refreshData,
        onLoad: controller.loadMoreData,
        enablePullDown: enablePullDown,
        enablePullUp: enablePullUp && controller.pagingState.hasMore,
        controller: controller,
        scrollController: controller.scrollController,
      );
    },
    tag: tag,
    id: controller.pagingState.refreshId,
  );
}

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
  bool showPageBar = false,
}) {
  C controller = Get.find(tag: tag);
  return GetBuilder<C>(
    builder: (controller) {
      return buildRefreshWidget<T, PagingController<T, PagingState<T>>>(
        builder: () =>
            buildCustomListView<T, PagingController<T, PagingState<T>>>(
                data: controller.pagingState.data,
                separatorBuilder: separatorBuilder,
                itemBuilder: itemBuilder,
                onItemClick: onItemClick,
                physics: physics,
                shrinkWrap: shrinkWrap,
                scrollDirection: scrollDirection,
                listEnum: listEnum,
                showPageBar: showPageBar,
                controller: controller,
                scrollController: controller.scrollController),
        scrollDirection: scrollDirection,
        refreshController: controller.refreshController,
        onRefresh: controller.refreshData,
        onLoad: controller.loadMoreData,
        enablePullDown: enablePullDown,
        enablePullUp: enablePullUp && controller.pagingState.hasMore,
        showPageBar: showPageBar,
        controller: controller,
        scrollController: controller.scrollController,
      );
    },
    tag: tag,
    id: controller.pagingState.refreshId,
  );
}

Widget buildListViewWidget<T>({
  required Widget Function(T item, int index) itemBuilder,
  required List<T> data,
  Widget Function(T item, int index)? separatorBuilder,
  Function(T item, int index)? onItemClick,
  ScrollPhysics? physics,
  bool shrinkWrap = false,
  Axis scrollDirection = Axis.vertical,

required ScrollController scrollController
}) {
  return ListView.builder(
    controller: scrollController,
    physics: physics,
    scrollDirection: scrollDirection,
    shrinkWrap: shrinkWrap,
    itemCount: data.length,
    // 指定列表项的数量
    itemBuilder: (ctx, index) {
      return GestureDetector(
        onTap: () => onItemClick?.call(data[index], index),
        child: itemBuilder(data[index], index),
      );
    },
  );
}

Widget buildGridViewWidget<T>({
  required Widget Function(T item, int index) itemBuilder,
  required List<T> data,
  Widget Function(T item, int index)? separatorBuilder,
  Function(T item, int index)? onItemClick,
  ScrollPhysics? physics,
  bool shrinkWrap = false,
  Axis scrollDirection = Axis.vertical,
required ScrollController scrollController
}) {
  return GridView.builder(
    controller: scrollController,
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

/// 构建页码导航栏
Widget buildPageNavigationBar<T, C extends PagingController<T, PagingState<T>>>(
    C controller) {
  return Container(
    padding: EdgeInsets.symmetric(vertical: 5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.first_page_rounded, size: 24),
          onPressed: () async {
            controller.pagingState.pageIndex = 1;
            await controller.pageNavigate();
            await controller.scrollToTop();
          },
        ),
        IconButton(
          icon: Icon(Icons.navigate_before_rounded, size: 24),
          onPressed: () async {
            await controller.pageSub();
          },
        ),
        // Obx(() => Text(
        //   '${controller.pagingState.pageIndex} / ${controller.pagingState.totalPages}',
        //   style: TextStyle(fontSize: 14),
        // )),
        IconButton(
          icon: Icon(Icons.navigate_next_rounded, size: 24),
          onPressed: () async {
            await controller.pageAdd();
          },
        ),
        IconButton(
          icon: Icon(Icons.last_page_rounded, size: 24),
          onPressed: () async {
            controller.pagingState.pageIndex =
                controller.pagingState.totalPages;
            await controller.pageNavigate();
            await controller.scrollToBottom();
          },
        ),
      ],
    ),
  );
}

Widget buildCustomListView<T, C extends PagingController<T, PagingState<T>>>(
    {required Widget Function(T item, int index) itemBuilder,
    required List<T> data,
    Widget Function(T item, int index)? separatorBuilder,
    Function(T item, int index)? onItemClick,
    ScrollPhysics? physics,
    bool shrinkWrap = false,
    Axis scrollDirection = Axis.vertical,
    ListEnum listEnum = ListEnum.grid,
    bool showPageBar = false,
    required C controller,
      required ScrollController scrollController}) {
  if (listEnum == ListEnum.list) {
    return buildListViewWidget(
        itemBuilder: itemBuilder,
        data: data,
        separatorBuilder: separatorBuilder,
        onItemClick: onItemClick,
        physics: physics,
        shrinkWrap: shrinkWrap,
        scrollDirection: scrollDirection,
        scrollController:scrollController);
    // );
  }

  return buildGridViewWidget(
      itemBuilder: itemBuilder,
      data: data,
      separatorBuilder: separatorBuilder,
      onItemClick: onItemClick,
      physics: physics,
      shrinkWrap: shrinkWrap,
      scrollDirection: scrollDirection,
      scrollController:scrollController,);
}

enum ListEnum { grid, list }

class CustomScrollNotification extends Notification {
  final double scrollOffset;

  CustomScrollNotification(this.scrollOffset);
}

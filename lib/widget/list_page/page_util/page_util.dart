
import 'package:flutter/cupertino.dart';
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

  @override
  void onInit() {
    super.onInit();

    /// 保存 State
    pagingState = getState();
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
  int size = 8;
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
      crossAxisCount: 2,
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

Widget buildRefreshWidget(
    {required Widget Function() builder,
      VoidCallback? onRefresh,
      VoidCallback? onLoad,
      required RefreshController refreshController,
      bool enablePullUp = true,
      bool enablePullDown = true}) {
  return SmartRefresher(
    enablePullUp: enablePullUp,
    enablePullDown: enablePullDown,
    controller: refreshController,
    onRefresh: onRefresh,
    onLoading: onLoad,
    header: const ClassicHeader(
      idleText: "下拉刷新",
      releaseText: "松开刷新",
      completeText: "刷新完成",
      refreshingText: "加载中......",
    ),
    footer: const ClassicFooter(
      idleText: "上拉加载更多",
      canLoadingText: "松开加载更多",
      loadingText: "加载中......",
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
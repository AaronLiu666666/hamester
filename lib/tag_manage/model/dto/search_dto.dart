/// 列表查询条件
class SearchDTO {
  // 查询框输入文本
  String? content;

  // 排序条件
  List<SearchOrder>? orders;

  SearchDTO({this.content, this.orders});
}

/// 排序字段
class SearchOrder {
  // 排序字段
  String? field;

  // 排序类型 asc desc
  String? orderType;

  SearchOrder({this.field, this.orderType});
}

class SearchResult<T> {
  // 查询结果列表
  List<T>? dataList;

  // 查询是否成功
  bool success;

  SearchResult({this.dataList, required this.success});
}


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

import 'package:floor/floor.dart';

class BaseObject {

  @PrimaryKey()
  final int id;

  /// 记录创建时间
  @ColumnInfo(name: "create_time")
  int createTime;

  /// 记录更新时间
  @ColumnInfo(name: "update_time")
  int updateTime;

  BaseObject(this.id, this.updateTime, this.createTime);
}
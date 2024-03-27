import 'package:floor/floor.dart';

/// 数据库标签实体
@Entity(tableName: "tag_info")
class TagInfo {
  @PrimaryKey()
  String? id;

  @ColumnInfo(name: "tag_name")
  String? tagName;

  @ColumnInfo(name: "tag_desc")
  String? tagDesc;

  @ColumnInfo(name: "tag_pic")
  String? tagPic;

  @ColumnInfo(name:"create_time")
  int? createTime;

  @ColumnInfo(name:"update_time")
  int? updateTime;

  /// 可选构造函数
  TagInfo({
    this.id,
    this.tagName,
    this.tagDesc,
    this.tagPic,
    this.createTime,
    this.updateTime,
  });

}


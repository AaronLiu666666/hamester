import 'package:floor/floor.dart';

/// 精彩时刻数据库实体
@Entity(tableName: "brilliant_time")
class BrilliantTimePO {

  /// 主键id
  @PrimaryKey()
  String? id;

  /// 精彩时刻类型 0 point 时间点 1 duration 时间段
  @ColumnInfo(name: "type")
  int? type;

  /// 精彩时刻描述
  @ColumnInfo(name: "brilliant_desc")
  String? brilliantDesc;

  /// 精彩时刻图片路径
  @ColumnInfo(name: "brilliant_pic")
  String? brilliantPic;

  /// 精彩时刻开始时间
  @ColumnInfo(name: "begin_moment")
  int beginMoment;

  /// 精彩时刻结束时间
  @ColumnInfo(name: "end_moment")
  int endMoment;

  /// 记录创建时间
  @ColumnInfo(name: "create_time")
  int createTime;

  /// 记录更新时间
  @ColumnInfo(name: "update_time")
  int updateTime;

  BrilliantTimePO(this.id, this.type, this.brilliantDesc, this.brilliantPic,
      this.beginMoment, this.endMoment, this.createTime, this.updateTime);
}

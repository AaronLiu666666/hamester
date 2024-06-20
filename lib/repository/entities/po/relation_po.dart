import 'package:floor/floor.dart';

/// Relation 关联数据库实体
@Entity(tableName: "relation")
class RelationPO {
  /// 主键id
  @PrimaryKey()
  final String id;

  /// 媒体id
  @ColumnInfo(name: "media_id")
  final String mediaId;

  /// 标签id
  @ColumnInfo(name: "tag_id")
  final String tagId;

  /// 精彩id
  @ColumnInfo(name: "brilliant_id")
  final String brilliantId;

  /// 关系描述
  @ColumnInfo(name: "relation_desc")
  final String relationDesc;

  /// 创建时间
  @ColumnInfo(name: "create_time")
  final int createTime;

  /// 结束时间
  @ColumnInfo(name: "end_time")
  final int endTime;

  RelationPO(
    this.id,
    this.mediaId,
    this.tagId,
    this.brilliantId,
    this.relationDesc,
    this.createTime,
    this.endTime,
  );
}

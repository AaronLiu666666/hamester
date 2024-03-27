import 'package:floor/floor.dart';

@Entity(tableName: "r_media_tag")
class MediaTagRelation {
  @PrimaryKey()
  String? id;

  @ColumnInfo(name: "media_id")
  int? mediaId;

  @ColumnInfo(name: "tag_id")
  String? tagId;

  @ColumnInfo(name: "media_moment")
  int? mediaMoment;

  @ColumnInfo(name: "relation_desc")
  String? relationDesc;

  @ColumnInfo(name: "media_moment_pic")
  String? mediaMomentPic;

  @ColumnInfo(name: "create_time")
  int? createTime;

  @ColumnInfo(name: "update_time")
  int? updateTime;

  MediaTagRelation({
    this.id,
    this.mediaId,
    this.tagId,
    this.mediaMoment,
    this.relationDesc,
    this.mediaMomentPic,
    this.createTime,
    this.updateTime,
  });

}

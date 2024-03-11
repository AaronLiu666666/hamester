import 'package:floor/floor.dart';

/**
 * 媒体文件数据库实体
 */
@Entity(
  tableName: "media_file_data"
)
class MediaFileData {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  String path;
  @ColumnInfo(name: "file_name")
  String fileName;
  @ColumnInfo(name: "file_alias")
  String fileAlias;
  @ColumnInfo(name: "file_md5")
  String fileMd5;
  @ColumnInfo(name: "source_url")
  String sourceUrl;
  @ColumnInfo(name:"memo")
  String memo;
  @ColumnInfo(name:"cover")
  String cover;
  @ColumnInfo(name:"last_play_moment")
  int lastPlayMoment;
  @ColumnInfo(name:"last_play_time")
  int lastPlayTime;
  @ColumnInfo(name:"play_num")
  int playNum;
  @ColumnInfo(name: "create_time")
  int createTime; // 修改为 int 类型
  @ColumnInfo(name: "update_time")
  int updateTime; // 修改为 int 类型

  MediaFileData(this.id, this.path, this.fileName, this.fileAlias, this.fileMd5,
      this.memo,
      this.cover,
      this.sourceUrl,
      this.lastPlayMoment,
      this.lastPlayTime,
      this.playNum,
      this.createTime, this.updateTime);

  // 可以添加一些帮助方法，用于在需要时转换为 DateTime
  DateTime get createTimeAsDateTime => DateTime.fromMillisecondsSinceEpoch(createTime);
  DateTime get updateTimeAsDateTime => DateTime.fromMillisecondsSinceEpoch(updateTime);
}

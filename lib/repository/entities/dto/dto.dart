import 'package:floor/floor.dart';

@DatabaseView("""
    SELECT
      r.*, t.tag_name as tagName, m.path as mediaPath
    FROM
      r_media_tag r
      LEFT JOIN tag_info t ON r.tag_id = t.id 
      LEFT JOIN media_file_data m ON r.media_id = m.id
      """, viewName: 'myJoinedObject')
class MediaTagRelationWithTagName {
  String? id;

  int? mediaId;

  String? tagId;

  int? mediaMoment;

  String? relationDesc;

  String? mediaMomentPic;

  int? createTime;

  int? updateTime;

  String? tagName;

  String? mediaPath;

  MediaTagRelationWithTagName(
      {this.id,
      this.mediaId,
      this.tagId,
      this.mediaMoment,
      this.relationDesc,
      this.mediaMomentPic,
      this.createTime,
      this.updateTime,
      this.tagName,
      this.mediaPath});

  // 从 Map 转换成 MediaTagRelationWithTagName 对象
  factory MediaTagRelationWithTagName.fromMap(Map<String, dynamic> map) {
    return MediaTagRelationWithTagName(
      id: map['id'] as String?,
      mediaId: map['mediaId'] as int?,
      tagId: map['tagId'] as String?,
      mediaMoment: map['mediaMoment'] as int?,
      relationDesc: map['relationDesc'] as String?,
      mediaMomentPic: map['mediaMomentPic'] as String?,
      createTime: map['createTime'] as int?,
      updateTime: map['updateTime'] as int?,
      tagName: map['tagName'] as String?,
      mediaPath: map['mediaPath'] as String?,
    );
  }
}

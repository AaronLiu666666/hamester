
import 'package:floor/floor.dart';
import 'package:hamster/media_manage/model/po/media_file_data.dart';

@dao
abstract class MediaFileDataDao {

  @Query("select * from media_file_data")
  Future<List<MediaFileData>> queryAllMediaFileDataList();


  @insert
  Future<void> insertMember(MediaFileData data);

  @insert
  Future<void> insertMembers(List<MediaFileData> list);


  @Query("SELECT * FROM media_file_data WHERE id IN (:ids)")
  Future<List<MediaFileData>> queryDatasByIds(List<int> ids);


  @Query("SELECT * FROM media_file_data WHERE id = :id")
  Future<MediaFileData?> queryMediaDataById(int id);

  @Query('''
  SELECT mfd.*
  FROM media_file_data mfd
  LEFT JOIN tag_info ti ON mfd.id = ti.id
  LEFT JOIN r_media_tag mtr ON mfd.id = mtr.media_id
  WHERE mfd.file_name LIKE '%' || :content || '%'
     OR mfd.file_alias LIKE '%' || :content || '%'
     OR mfd.memo LIKE '%' || :content || '%'
     OR ti.tag_name LIKE '%' || :content || '%'
     OR ti.tag_desc LIKE '%' || :content || '%'
     OR mtr.relation_desc LIKE '%' || :content || '%'
''')
  Future<List<MediaFileData>> searchMedia(String content);
}
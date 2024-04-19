
import 'package:floor/floor.dart';
import 'package:hamster/media_manage/model/po/media_file_data.dart';

import '../../tag_manage/model/dto/search_dto.dart';

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
  LEFT JOIN r_media_tag mtr ON mfd.id = mtr.media_id
	LEFT JOIN tag_info ti ON mtr.tag_id = ti.id
  WHERE mfd.file_name LIKE '%' || :content || '%'
     OR mfd.file_alias LIKE '%' || :content || '%'
     OR mfd.memo LIKE '%' || :content || '%'
     OR ti.tag_name LIKE '%' || :content || '%'
     OR ti.tag_desc LIKE '%' || :content || '%'
     OR mtr.relation_desc LIKE '%' || :content || '%'
''')
  Future<List<MediaFileData>> searchMedia(String content);

  @Query('''
  SELECT mfd.*
  FROM media_file_data mfd
  LEFT JOIN r_media_tag mtr ON mfd.id = mtr.media_id
	LEFT JOIN tag_info ti ON mtr.tag_id = ti.id
  WHERE 
    (:content IS NULL OR mfd.file_name LIKE '%' || :content || '%') OR
    (:content IS NULL OR mfd.file_alias LIKE '%' || :content || '%') OR
    (:content IS NULL OR mfd.memo LIKE '%' || :content || '%') OR
    (:content IS NULL OR ti.tag_name LIKE '%' || :content || '%') OR
    (:content IS NULL OR ti.tag_desc LIKE '%' || :content || '%') OR
    (:content IS NULL OR mtr.relation_desc LIKE '%' || :content || '%')
    group by mfd.id
    order by mfd.create_time,mfd.id
  LIMIT :limit OFFSET :offset
''')
  Future<List<MediaFileData>> searchMediaPage(String content, int limit, int offset);

  @Query('''
  SELECT mfd.*
  FROM media_file_data mfd
  LEFT JOIN r_media_tag mtr ON mfd.id = mtr.media_id
	LEFT JOIN tag_info ti ON mtr.tag_id = ti.id
	where ti.id is null
    group by mfd.id
    order by mfd.create_time,mfd.id
  LIMIT :limit OFFSET :offset
''')
  Future<List<MediaFileData>> searchMediaPageWithoutTag(int limit, int offset);

  @Query('''
  SELECT mfd.*
  FROM media_file_data mfd
  LEFT JOIN r_media_tag mtr ON mfd.id = mtr.media_id
	LEFT JOIN tag_info ti ON mtr.tag_id = ti.id
	where 
	  ti.tag_name like :tag || '%'
    group by mfd.id
    order by mfd.create_time,mfd.id
  LIMIT :limit OFFSET :offset
''')
  Future<List<MediaFileData>> searchMediaPageWithTag(String tag,int limit, int offset);

  @Query('''
  SELECT count(DISTINCT mfd.id)
  FROM media_file_data mfd
  LEFT JOIN r_media_tag mtr ON mfd.id = mtr.media_id
	LEFT JOIN tag_info ti ON mtr.tag_id = ti.id
  WHERE 
    (:content IS NULL OR mfd.file_name LIKE '%' || :content || '%') OR
    (:content IS NULL OR mfd.file_alias LIKE '%' || :content || '%') OR
    (:content IS NULL OR mfd.memo LIKE '%' || :content || '%') OR
    (:content IS NULL OR ti.tag_name LIKE '%' || :content || '%') OR
    (:content IS NULL OR ti.tag_desc LIKE '%' || :content || '%') OR
    (:content IS NULL OR mtr.relation_desc LIKE '%' || :content || '%')
''')
  Future<int?> searchMediaCount(String content);

  @update
  Future<void> updateData(MediaFileData mediaFileData);

}
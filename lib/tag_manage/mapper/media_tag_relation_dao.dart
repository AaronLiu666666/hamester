
import 'package:floor/floor.dart';

import '../model/po/media_tag_relation.dart';

@dao
abstract class MediaTagRelationDao {

  @insert
  Future<void> insertOne(MediaTagRelation mediaTagRelation);

  @insert
  Future<void> insertList(List<MediaTagRelation> list);

  @Query("select * from r_media_tag")
  Future<List<MediaTagRelation>> queryAllDataList();

  @Query("select * from r_media_tag where tag_id = :tagId")
  Future<List<MediaTagRelation>> queryRelationsByTagId(String tagId);

  @Query('''
    select r.*,t.tag_name tagName, m.path as mediaPath
      from r_media_tag r LEFT JOIN tag_info t on r.tag_id = t.id left join media_file_data m on r.media_id = m.id
    where 
      r.media_id = :mediaId 
      order by media_moment
  ''')
  Future<List<MediaTagRelation>> queryRelationsByMediaId(int mediaId);

  @Query('''
      select r.*, m.path as mediaPath
      from 
      r_media_tag r left join media_file_data m on r.media_id = m.id
        where tag_id = :tagId
  ''')
  Future<List<MediaTagRelation>> queryRelationsByTagIdWithMediaPath(String tagId);

  @Query("select * from r_media_tag where id = :id")
  Future<MediaTagRelation?> queryRelationById(String id);

  @update
  Future<void> updateRelation(MediaTagRelation relation);

  @Query("select r.*,t.tag_name as tagName from r_media_tag r LEFT JOIN tag_info t on r.tag_id = t.id")
  Future<List<MediaTagRelation>> queryAllDataListWithTagName();

  @Query('''
  SELECT
    count(r.id) 
  FROM
    r_media_tag r
    LEFT JOIN tag_info t ON r.tag_id = t.id 
  WHERE
   (:content IS NULL OR r.relation_desc LIKE '%' || :content || '%') OR
   (:content IS NULL OR t.tag_name LIKE '%' || :content || '%') OR
   (:content IS NULL OR t.tag_desc LIKE '%' || :content || '%')
  ''')
  Future<int?> searchRelationCount(String content);

  @Query('''
  SELECT
    r.*,t.tag_name as tagName,m.path as mediaPath
  FROM
    r_media_tag r
    LEFT JOIN tag_info t ON r.tag_id = t.id 
    LEFT JOIN media_file_data m on r.media_id = m.id
  WHERE
   (:content IS NULL OR r.relation_desc LIKE '%' || :content || '%') OR
   (:content IS NULL OR t.tag_name LIKE '%' || :content || '%') OR
   (:content IS NULL OR t.tag_desc LIKE '%' || :content || '%')
    order by r.create_time,r.id
    LIMIT :limit OFFSET :offset
  ''')
  Future<List<MediaTagRelation>> searchRelationPage(String content, int limit, int offset);

  @Query('''
    delete from r_media_tag where media_id = :mediaId
  ''')
  Future<void> deleteRelationByMediaId(int mediaId);

  @Query('''
    delete from r_media_tag where tag_id = :tagId
  ''')
  Future<void> deleteRelationByTagId(String tagId);

  @Query('''
    delete from r_media_tag where id = :relationId
    ''')
  Future<void> deleteRelationById(String relationId);

}
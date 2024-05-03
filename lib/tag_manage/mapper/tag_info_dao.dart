import 'package:floor/floor.dart';

import '../model/po/tag_info.dart';

@dao
abstract class TagInfoDao {
  @insert
  Future<void> insertOne(TagInfo tagInfo);

  @insert
  Future<void> insertList(List<TagInfo> list);

  @Query('SELECT * FROM tag_info WHERE tag_name = :tagName')
  Future<List<TagInfo>> queryTagsByTagName(String tagName);

  @Query("select * from tag_info")
  Future<List<TagInfo>> queryAllDataList();

  @Query("select * from tag_info where id = :id")
  Future<TagInfo?> queryDataById(String id);

  @Query('''
    SELECT
     t.*
    FROM
      r_media_tag r
      LEFT JOIN tag_info t ON r.tag_id = t.id 
    WHERE
      r.media_id = :mediaId 
      group by r.tag_id
      order by r.create_time
  ''')
  Future<List<TagInfo>> queryTagsByMediaId(int mediaId);

  @update
  Future<void> updateData(TagInfo tagInfo);

  @Query('''
  select count(*) from tag_info where 
  (:content IS NULL OR tag_name LIKE '%' || :content || '%') or (:content IS NULL OR tag_desc LIKE '%' || :content || '%')
  ''')
  Future<int?> searchTagCount(String content);

  @Query('''
  select * from tag_info where 
    (:content IS NULL OR tag_name LIKE '%' || :content || '%') or (:content IS NULL OR tag_desc LIKE '%' || :content || '%')
    order by create_time,id
    LIMIT :limit OFFSET :offset
  ''')
  Future<List<TagInfo>> searchTagInfoPage(String content, int limit, int offset);

  @Query('''
  select * from tag_info where 
    (tag_name LIKE '%' || :tagName || '%')
    order by create_time,id
  ''')
  Future<List<TagInfo>> searchTagInfoListByTagName(String tagName);

  @Query('''
     delete from tag_info where id = :tagId
    ''')
  Future<void> deleteTagById(String tagId);
}

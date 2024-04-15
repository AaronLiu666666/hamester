
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

  @Query("select * from r_media_tag where id = :id")
  Future<MediaTagRelation?> queryRelationById(String id);

  @update
  Future<void> updateRelation(MediaTagRelation relation);

  @Query("select r.*,t.tag_name as tagName from r_media_tag r LEFT JOIN tag_info t on r.tag_id = t.id")
  Future<List<MediaTagRelation>> queryAllDataListWithTagName();

}


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

}
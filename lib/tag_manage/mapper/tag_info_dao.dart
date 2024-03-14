

import 'package:floor/floor.dart';

import '../model/po/tag_info.dart';

@dao
abstract class TagInfoDao {

  @insert
  Future<void> insertOne(TagInfo tagInfo);

  @insert
  Future<void> insertList(List<TagInfo> list);

}
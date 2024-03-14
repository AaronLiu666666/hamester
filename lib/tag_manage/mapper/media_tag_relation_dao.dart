
import 'package:floor/floor.dart';

import '../model/po/media_tag_relation.dart';

@dao
abstract class MediaTagRelationDao {


  @insert
  Future<void> insertOne(MediaTagRelation mediaTagRelation);

  @insert
  Future<void> insertList(List<MediaTagRelation> list);

}
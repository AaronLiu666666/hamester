
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

}
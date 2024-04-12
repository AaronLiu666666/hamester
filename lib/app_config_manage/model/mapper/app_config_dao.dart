
import 'package:floor/floor.dart';

import '../po/app_config_po.dart';

@dao
abstract class AppConfigDao {

  @insert
  Future<void> insertAppConfig(AppConfig appConfig);

  @update
  Future<void> updateAppConfig(AppConfig appConfig);

  @Query("select * from app_config where type = :configType limit 1")
  Future<AppConfig?> selectAppConfigByType(String configType);

}
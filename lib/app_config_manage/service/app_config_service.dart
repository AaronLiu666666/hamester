

import 'package:hamster/app_config_manage/model/enums/app_config_constant.dart';

import '../../config/db/flutter_data_base.dart';
import '../../config/db/flutter_database_manager.dart';
import '../model/po/app_config_po.dart';

// 更新或者新增app配置信息
Future<void> insertOrUpdateAppConfig(AppConfig appConfigInfo) async {
  if(appConfigInfo==null||appConfigInfo.type==null||appConfigInfo.type!.isEmpty){
    return;
  }
  final FlutterDataBase dataBase = await FlutterDataBaseManager.database();
  AppConfig? appConfig = await dataBase.appConfigDao.selectAppConfigByType(appConfigInfo.type!);
  if(null == appConfig) {
    int timeStamp = DateTime.now().millisecondsSinceEpoch;
    appConfig = AppConfig(
      id:null,
      type:appConfigInfo.type,
      content:appConfigInfo.content,
      createTime:timeStamp,
      updateTime:timeStamp,
    );
    await dataBase.appConfigDao.insertAppConfig(appConfig);
  } else {
    appConfig.type = appConfigInfo.type;
    appConfig.content = appConfigInfo.content;
    await dataBase.appConfigDao.updateAppConfig(appConfig);
  }
}

Future<AppConfig?> getAppConfigByType(String type) async{
  final FlutterDataBase dataBase = await FlutterDataBaseManager.database();
  AppConfig? appConfig = await dataBase.appConfigDao.selectAppConfigByType(type);
  return appConfig;
}

Future<List<String>> getMediaSearchConfigList() async{
  AppConfig? appConfig = await getAppConfigByType(AppConfigConstant.MEDIA_SEARCH_CONFIG);
  if(null!=appConfig){
    String? pathConcat = appConfig.content;
    if(null!=appConfig.content&&appConfig.content!.isNotEmpty){
      return pathConcat!.split(",");
    }
  }
  return List.empty();
}
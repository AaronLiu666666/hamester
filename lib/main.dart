import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hamster/providers/search_provider.dart';
import 'package:hamster/utils/log_utils.dart';
import 'package:hamster/widget/flutter_bricks/course_screen.dart';
import 'package:hamster/widget/list_page/media_home_page.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 加载配置
  await dotenv.load();
  bool isDebugMode = !kReleaseMode;
  LogUtils.init(isDebug: isDebugMode);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MediaSearchProvider(), // 提供状态管理器
      child: MaterialAppScaffoldWidget(),
    );
  }
}

class MaterialAppScaffoldWidget extends StatelessWidget {
  // 定义路由变量
  final routes = {
    // '/videoPlayChewie':(context,{arguments})=>VideoChewiePage(videoId: arguments["videoId"] as int,videoPath: arguments['videoPath'] as String)
  };

  @override
  Widget build(BuildContext context) {
    // 使用GetMaterialApp替换flutter原始MaterialApp 这样可以使用 Getx 的 Get.to 导航路由，同时也能兼容原生路由方式
    return GetMaterialApp(
        home: MediaHomePage(),
        // home: CourseScreen(
        //     courseName: "courseName",
        //     courseImage: AssetImage('assets/image/no-pictures.png'),
        //     courseInfo:
        //         "It gives a superpower to developers to customize the code as their requirements also they directly see the output before using.",
        //     coursePrice: "100"),
        theme: ThemeData(
          primarySwatch: Colors.yellow,
        ),
        onGenerateRoute: (RouteSettings settings) {
          // 统一处理
          final String? name = settings.name;
          final Function? pageContentBuilder = routes[name];
          if (pageContentBuilder != null) {
            if (settings.arguments != null) {
              final Route route = MaterialPageRoute(
                  builder: (context) => pageContentBuilder(context,
                      arguments: settings.arguments));
              return route;
            } else {
              final Route route = MaterialPageRoute(
                  builder: (context) => pageContentBuilder(context));
              return route;
            }
          }
        });
  }
}

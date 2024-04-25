import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hamster/providers/search_provider.dart';
import 'package:hamster/widget/list_page/media_home_page.dart';
import 'package:hamster/widget/video_chewie/video_chewie_page.dart';
import 'package:hamster/widget/video_chewie/video_horizontal_scroll_widget.dart';
import 'package:provider/provider.dart';

void main() async {
  // 加载配置
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  // 延迟注册 VideoHorizontalScrollPagingController 单例
  // Get.lazyPut<VideoHorizontalScrollPagingController>(() => VideoHorizontalScrollPagingController());
  runApp(new MyApp());
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
    '/videoPlayChewie':(context,{arguments})=>VideoChewiePage(videoId: arguments["videoId"] as int,videoPath: arguments['videoPath'] as String)
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: MediaHomePage(),
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
                  builder: (context) =>
                      pageContentBuilder(context, arguments: settings.arguments));
              return route;
            } else {
              final Route route = MaterialPageRoute(
                  builder: (context) => pageContentBuilder(context));
              return route;
            }
          }
        }
    );
  }
}

import 'package:floor/floor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:hamster/widget/MediaShowWidget.dart';
import 'package:hamster/widget/VideoPlayWidget.dart';
import 'package:hamster/widget/debug_widget.dart';
import 'package:hamster/widget/video/video_player_page.dart';
import 'package:hamster/widget/video/video_player_ui.dart';
import 'package:video_player/video_player.dart';
import 'config/db/flutter_data_base.dart';
import 'db/db_init.dart';
import 'res/listData.dart';
import 'customWidget/mainPage.dart';
import 'customWidget/fileList.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  // 加载配置
  WidgetsFlutterBinding.ensureInitialized();
  // await FlutterConfig.loadEnvVariables();
  // final database = await $FloorFlutterDataBase
  //     .databaseBuilder('data.db')
  //     .addMigrations([FlutterDataBase.getMigration1to2()]) // 使用静态方法
  //     .build();
  await dotenv.load();
  runApp(new MaterialAppScaffoldWidget());
}

String imageUrl1 =
    "https://picx.zhimg.com/50/v2-139627556961d50c4f9b27badce0b99e_720w.jpg?source=1def8aca";
String imageUrl2 =
    "https://pica.zhimg.com/80/v2-e4409c6747bec6b9ac5d22e5dc299747_1440w.webp?source=1def8aca";

class CenterWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Hello Flutter',
        textDirection: TextDirection.ltr,
        style: TextStyle(
          fontSize: 40.0,
          color: Colors.blue,
        ),
      ),
    );
  }
}

class ContainerTextWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
      child: Text("Hello Flutter"),
      alignment: Alignment.topCenter,
      height: 300.0,
      width: 300.0,
      decoration: BoxDecoration(
          color: Colors.blue,
          border: Border.all(
            color: Colors.blue,
            width: 2.0,
          )),
    ));
  }
}

class ContainerImageWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          color: Colors.blue,
        ),
        child: Image.network(
          imageUrl1,
          alignment: Alignment.topLeft,
          fit: BoxFit.contain,
          repeat: ImageRepeat.repeat,
        ),
      ),
    );
  }
}

/**
 * 使用BoxDecoration实现图片圆角
 */
class ContainerBoxDecorationImageClass extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(150),
            image: DecorationImage(
              image: NetworkImage(imageUrl1),
              fit: BoxFit.contain,
              repeat: ImageRepeat.repeat,
            )),
      ),
    );
  }
}

/**
 *  使用ClipOval实现图片圆角
 */
class ContainerClipOvalImageWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: ClipOval(
          child: Image.network(
            imageUrl1,
            height: 200,
            width: 200,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

/**
 *  使用ClipOval实现图片圆角-加载本地图片
 */
class ContainerClipOvalAssetImageWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: ClipOval(
          child: Image.asset(
            "assets/image/image_1.png",
            height: 200,
            width: 200,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

/**
 * 列表 垂直列表
 */
class VerticalListViewWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(10),
      children: <Widget>[
        ListTile(
          leading: Icon(
            Icons.settings,
            color: Colors.blue,
            size: 30,
          ),
          title: Text("列表第一条数据",
              style: TextStyle(
                fontSize: 16,
              )),
          subtitle: Text("列表第一条数据具体内容"),
          trailing: Icon(Icons.sentiment_satisfied_sharp),
        ),
        ListTile(
          leading: Image.network(imageUrl1),
          title: Text("列表第二条数据"),
          subtitle: Text("列表第二条数据具体内容"),
        )
      ],
    );
  }
}

/**
 * 列表 水平列表
 */
class HorizontalListViewWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: <Widget>[
        Container(
          width: 180,
          color: Colors.blue,
        ),
        Container(
          width: 180,
          color: Colors.red,
        ),
        Container(
          width: 180,
          color: Colors.blue,
          child: ListView(
            children: <Widget>[
              Image.network(imageUrl1),
              Image.network(imageUrl1),
              Image.network(imageUrl1),
              Image.network(imageUrl1),
              Image.network(imageUrl1),
              Image.network(imageUrl1),
              Image.network(imageUrl1),
              Image.network(imageUrl1),
            ],
          ),
        )
      ],
    );
  }
}

class ListViewBuilderWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: listData.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Image.network(listData[index]["imgUrl"]),
          title: Text(listData[index]["title"]),
          subtitle: Text(listData[index]["author"]),
        );
      },
    );
  }
}

class GridViewCountWidget extends StatelessWidget {
  List<Widget> _getListData() {
    var tempList = listData.map((value) {
      return Container(
        // Column Widget 就是把里面的children的东西竖着放然后作为一个整体Widget
        child: Column(
          children: <Widget>[
            Image.network(value["imgUrl"]),
            SizedBox(
              height: 10,
            ),
            Text(value["title"]),
          ],
        ),
      );
    });
    return tempList.toList();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      // 横的数量
      crossAxisCount: 2,
      // 横的间距
      crossAxisSpacing: 20,
      // 纵的间距
      mainAxisSpacing: 20,
      padding: EdgeInsets.all(10),
      children: this._getListData(),
    );
  }
}

class GridViewBuilderWidget extends StatelessWidget {
  Widget _getListData(Context, index) {
    return Container(
      child: Column(
        children: <Widget>[
          Image.network(listData[index]["imgUrl"]),
          SizedBox(
            height: 10,
          ),
          Text(listData[index]["title"]),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: listData.length,
      itemBuilder: this._getListData,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
    );
  }
}

/**
 * 自适应 widget
 */
class ExpandedWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          // 如果不写这个flex，那么这个就固定宽度，写了flex的就自适应，这个flex数字表示占据的份额，即 该flex/所有flex的和 = 占得比例
          flex: 5,
          child: Image.network(imageUrl1),
        ),
        Expanded(
          flex: 2,
          child: Image.network(imageUrl2),
        )
      ],
    );
  }
}

class StackWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

class MaterialAppScaffoldWidget extends StatelessWidget {

  // 定义路由变量
  final routes = {
    '/videoPlay': (context, {arguments}) => VideoPlayerPage(videoUrl: arguments['videoSource'] as String),
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: Text("Flutter Demo"),
              backgroundColor: Colors.blue,
            ),
            // body: CenterWidget(),
            // body: ContainerTextWidget(),
            // body: ContainerImageWidget(),
            // body: ContainerImageWidget(),
            // body: ContainerBoxDecorationImageClass(),
            // body: ContainerClipOvalImageWidget(),
            // body: ContainerClipOvalAssetImageWidget(),
            // body: VerticalListViewWidget(),
            // body: ListViewBuilderWidget(),
            // body: HorizontalListViewWidget(),
            // body: GridViewCountWidget(),
            // body: GridViewBuilderWidget(),
            // body: ExpandedWidget(),
            // body: CardWidget(
            //   data: CardContentData(
            //     url: imageUrl1,
            //     text: "测试文本",
            //   ),
            // ),
            // body: MainPageWidget(),
            // body: FileListWidget(),
            body: Column(
              children: <Widget>[
                DebugWidget(),
                Expanded(
                  child: MediaShowWidget(),
                ),
              ],
            ),
          // body: VideoApp(videoSource: "/storage/emulated/0/Download/D3.mp4"),
          // body: VideoPlayerUI(),
          // body: VideoPlayerPage(),
        ),
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

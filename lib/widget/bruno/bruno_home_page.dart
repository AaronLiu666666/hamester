import 'package:bruno/bruno.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hamster/utils/log_utils.dart';

import 'custom_app_bar.dart';

class BrunoHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    LogUtils.d("状态栏高度：$statusBarHeight");
    double appBarHeight = AppBar().preferredSize.height;
    LogUtils.d("appBar高度：$appBarHeight");
    return Scaffold(
      // appBar: BrnSearchAppbar(
      //   leading: IconButton(
      //     icon: const Icon(Icons.menu,color: Colors.white,), onPressed: () {  },
      //   ),
      //   themeData: BrnAppBarConfig(backgroundColor: Colors.blue),
      //   showDivider: false,
      //
      // ),
      appBar: AppBar(
        leading: Icon(Icons.menu),
        title: SearchBar(
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
          ),
          leading: Icon(Icons.search),
          hintText: "请输入搜索内容...",
          backgroundColor: MaterialStateProperty.all(
              Colors.white
          ),
        ),

        actions: [TextButton(onPressed: () {}, child: Text("搜索"))],
      ),
      // appBar: BrnAppBar(
      //   // themeData: BrnAppBarConfig(backgroundColor: Colors.blue),
      //   themeData: BrnAppBarConfig.light(),
      //   leading: IconButton(
      //     icon: const Icon(Icons.menu),
      //     onPressed: () {},
      //   ),
      //   title: BrnSearchText(),
      //   // actions: ,
      // ),
      // appBar: AppBar(
      //   leading: Icon(Icons.menu),
      //   title: BrnSearchText(),
      //   bottom: PreferredSize(
      //     preferredSize: Size.fromHeight(10),
      //     child: Icon(Icons.add),
      //   )
      // ),
      bottomNavigationBar: BrnBottomTabBar(
        items: <BrnBottomTabBarItem>[
          BrnBottomTabBarItem(icon: Icon(Icons.tag), title: Text("标签库")),
          BrnBottomTabBarItem(icon: Icon(Icons.movie), title: Text("媒体库")),
          BrnBottomTabBarItem(icon: Icon(Icons.link), title: Text("关联库"))
        ],
      ),
    );
  }
}

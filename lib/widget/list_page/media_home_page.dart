import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:hamster/widget/config_page/media_search_config_page.dart';
import 'package:provider/provider.dart';

import '../../providers/search_provider.dart';
import '../../tag_manage/model/dto/search_dto.dart';
import 'media_list_page.dart';
import 'media_page_list_page.dart';
import 'media_tag_relation_list_page.dart';
import 'tag_list_page.dart';

/// 首页：展示 标签列表 媒体列表 关联列表 并切换，有搜索框
class MediaHomePage extends StatefulWidget {
  @override
  _MediaHomePageState createState() => _MediaHomePageState();
}

class _MediaHomePageState extends State<MediaHomePage> {
  int _selectedIndex = 1;

  List<Widget> _widgetOptions = <Widget>[
    TagListPage(),
    // MediaListPage(),
    MediaPageListPage(),
    MediaTagRelationListPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0), // 设置高度为0
        child: AppBar(
          backgroundColor: Colors.transparent, // 设置背景色为透明
          elevation: 0,
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            ListTile(
              title: Text('媒体文件扫描目录'),
              onTap: () {
                // Do something
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MediaSearchConfigPage(),
                  ),
                );
              },
            ),
            // ListTile(
            //   title: Text('Item 2'),
            //   onTap: () {
            //     // Do something
            //   },
            // ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,

        children: [
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: SearchWidget(
          //     onSearch: _handleSearch,
          //   ),
          // ),
          Builder(
            builder: (context) => Row(
              children: [
                IconButton(
                  icon: Icon(Icons.menu),
                  onPressed: () {
                    // 打开侧边栏
                    Scaffold.of(context).openDrawer();
                  },
                ),
                Expanded(
                  // 添加Expanded
                  child: SearchWidget(onSearch: _handleSearch),
                ),
              ],
            ),
          ),
          Expanded(
            child: _widgetOptions.elementAt(_selectedIndex),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.tag),
            label: '标签库',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.movie),
            label: '媒体库',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.link),
            label: '关联库',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  void _handleSearch(SearchDTO searchDTO) {
    // 获取 Provider
    // final mediaSearchProvider =
    //     Provider.of<MediaSearchProvider>(context, listen: false);
    // // 更新搜索状态
    // mediaSearchProvider.setSearchDTO(searchDTO);
    // 调用 _search 方法执行搜索
    // 找到 MediaPagingController
    if(_selectedIndex == 1) {
      MediaPagingController controller = Get.find<MediaPagingController>();
      // 刷新数据
      controller.refreshDataNotScan();
    }
  }

}

// class SearchWidget extends StatefulWidget {
//   final Function(SearchDTO) onSearch; // 回调函数，用于传递搜索条件
//
//   const SearchWidget({Key? key, required this.onSearch}) : super(key: key);
//
//   @override
//   _SearchWidgetState createState() => _SearchWidgetState();
// }
//
// class _SearchWidgetState extends State<SearchWidget> {
//   // String? _searchText; // 搜索框文本
//   Set<String> _selectedFields = {}; // 选中的排序字段
//   Map<String, bool> _orderTypes = {}; // 排序类型与方向的映射
//
//   // 使用controller是为了 在点击x叉号清除搜索内容时，用controller的clear清空内容
//   TextEditingController _searchController = TextEditingController(); // 添加一个TextEditingController
//
//
//   List<String> _fields = ['Field 1', 'Field 2', 'Field 3']; // 排序字段列表
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Row(
//         children: [
//           // 搜索框 自适应
//           Expanded(
//             child: TextFormField(
//               controller: _searchController,
//               onChanged: (value) {
//                 setState(() {
//                   // _searchText = value;
//                   _searchController.text = value;
//                 });
//               },
//               decoration: InputDecoration(
//                 hintText: '搜索内容...',
//                 // 提示文本
//                 prefixIcon: Icon(Icons.search),
//                 // 前缀图标
//                 border: OutlineInputBorder(
//                   // 边框样式
//                   borderRadius: BorderRadius.circular(10.0), // 边框圆角
//                   borderSide: BorderSide(color: Colors.grey), // 边框颜色
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   // 获得焦点时的边框样式
//                   borderRadius: BorderRadius.circular(10.0), // 边框圆角
//                   borderSide: BorderSide(color: Colors.blue), // 边框颜色
//                 ),
//                 contentPadding: EdgeInsets.symmetric(
//                     vertical: 8.0, horizontal: 10.0), // 调整文本的垂直内边距
//               ),
//             ),
//           ),
//           SizedBox(width: 5),
//           Visibility(
//             // 搜索内容非空显示叉号
//             visible: _searchController.text.isNotEmpty,
//             child: GestureDetector(
//               onTap: () {
//                 setState(() {
//                   // _searchText = ""; // 清空搜索框内容
//                   // 点击清除按钮时，清空TextEditingController中的文本内容
//                   _searchController.clear();
//                 });
//                 SearchDTO searchDTO = SearchDTO(
//                   content: _searchController.text,
//                   orders: _selectedFields.isNotEmpty
//                       ? _selectedFields.map((field) {
//                     return SearchOrder(
//                       field: field,
//                       orderType: _orderTypes[field]! ? 'asc' : 'desc',
//                     );
//                   }).toList()
//                       : null,
//                 );
//                 widget.onSearch(searchDTO);
//               },
//               child: Icon(Icons.clear), // 清除按钮
//             ),
//           ),
//           SizedBox(
//             height: 50,
//             child: TextButton(
//               onPressed: () {
//                 // 构建搜索条件对象
//                 SearchDTO searchDTO = SearchDTO(
//                   content: _searchController.text,
//                   orders: _selectedFields.isNotEmpty
//                       ? _selectedFields.map((field) {
//                           return SearchOrder(
//                             field: field,
//                             orderType: _orderTypes[field]! ? 'asc' : 'desc',
//                           );
//                         }).toList()
//                       : null,
//                 );
//                 // 调用回调函数传递搜索条件
//                 widget.onSearch(searchDTO);
//               },
//               style: ButtonStyle(
//                 backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
//                 // 设置按钮背景色
//                 foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
//                 // 设置文字颜色
//                 padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
//                     const EdgeInsets.all(15)),
//                 // 设置按钮内边距
//                 shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//                   RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8.0), // 设置按钮圆角
//                   ),
//                 ),
//               ),
//               child: Text('搜索'),
//             ),
//           )
//         ],
//       ),
//     );
//   }
//   @override
//   void dispose() {
//     _searchController.dispose(); // 释放资源
//     super.dispose();
//   }
// }

class SearchWidget extends StatelessWidget {
  final Function(SearchDTO) onSearch; // 回调函数，用于传递搜索条件

  const SearchWidget({Key? key, required this.onSearch}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CustomSearchController controller = Get.put(CustomSearchController(onSearch: onSearch)); // 初始化并放置控制器

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GetBuilder<CustomSearchController>(
        builder: (controller) => Row(
          children: [
            // 搜索框 自适应
            Expanded(
              child: TextFormField(
                controller: controller.textEditingController,
                onChanged: (value) {
                  controller.updateSearchText(value); // 更新搜索文本
                },
                decoration: InputDecoration(
                  hintText: '搜索内容...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 10.0),
                ),
              ),
            ),
            SizedBox(width: 5),
            Visibility(
              visible: controller.textEditingController.text.isNotEmpty,
              child: GestureDetector(
                onTap: () {
                  controller.clearSearchText(); // 清除搜索文本
                  controller.performSearch(); // 执行搜索
                },
                child: Icon(Icons.clear),
              ),
            ),
            SizedBox(
              height: 50,
              child: TextButton(
                onPressed: () {
                  controller.performSearch(); // 执行搜索
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.all(15)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                child: Text('搜索'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class CustomSearchController extends GetxController {
  TextEditingController textEditingController = TextEditingController(); // 搜索文本控制器
  final Function(SearchDTO) onSearch; // 添加回调函数

  CustomSearchController({required this.onSearch}); // 在构造函数中接收onSearch函数

  void updateSearchText(String value) {
    textEditingController.text = value;
  }

  void clearSearchText() {
    textEditingController.clear();
  }

  void performSearch() {
    SearchDTO searchDTO = SearchDTO(
      content: textEditingController.text,
      orders: [], // 添加您的排序逻辑
    );
    // 调用回调函数传递搜索条件
    // 这里假设onSearch是从父组件传递的函数
    onSearch(searchDTO);
  }

  @override
  void dispose() {
    textEditingController.dispose(); // 释放资源
    super.dispose();
  }

  SearchDTO getSearchDTO(){
    SearchDTO searchDTO = SearchDTO(content: textEditingController.text);
    return searchDTO;
  }
}

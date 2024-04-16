import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:hamster/widget/config_page/media_search_config_page.dart';
import '../../tag_manage/model/dto/search_dto.dart';
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

  late CustomSearchController searchController; // 声明控制器变量

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
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,

        children: [
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
    searchController = Get.put(CustomSearchController(onSearch: _handleSearch)); // 初始化并放置控制器
  }


  @override
  void dispose() {
    searchController.dispose(); // 清理搜索控制器
    super.dispose();
  }

  void _handleSearch(SearchDTO searchDTO) {
    // 标签库
    if(_selectedIndex==0){

    }
    // 媒体库
    if(_selectedIndex == 1) {
      MediaPagingController controller = Get.find<MediaPagingController>();
      // 刷新数据
      controller.refreshDataNotScan();
    }
    // 关连库
    if(_selectedIndex==2){

    }
  }

}

class SearchWidget extends StatelessWidget {
  final Function(SearchDTO) onSearch; // 回调函数，用于传递搜索条件

  const SearchWidget({Key? key, required this.onSearch}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final CustomSearchController controller = Get.put(CustomSearchController(onSearch: onSearch)); // 初始化并放置控制器
    final CustomSearchController controller = Get.find<CustomSearchController>();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Obx(() {
        return Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller.textEditingController,
                onChanged: (value) {
                  controller.updateSearchText(value);
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
                  contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                ),
              ),
            ),
            SizedBox(width: 5),
            Visibility(
              visible: controller.searchText.value.isNotEmpty,
              child: GestureDetector(
                onTap: () {
                  controller.clearSearchText();
                  controller.performSearch();
                },
                child: Icon(Icons.clear),
              ),
            ),
            SizedBox(
              height: 50,
              child: TextButton(
                onPressed: () {
                  controller.performSearch();
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.all(15)),
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
        );
      }),
    );
  }
}

class CustomSearchController extends GetxController {
  RxString searchText = ''.obs; // 使用 RxString 来存储搜索文本
  final TextEditingController textEditingController = TextEditingController(); // 添加TextEditingController
  final Function(SearchDTO) onSearch; // 添加回调函数

  CustomSearchController({required this.onSearch}) {
    textEditingController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    searchText.value = textEditingController.text;
  }

  void updateSearchText(String value) {
    textEditingController.text = value;
    searchText.value = value;
  }

  void clearSearchText() {
    textEditingController.clear();
    searchText.value = '';
  }

  void performSearch() {
    SearchDTO searchDTO = SearchDTO(
      content: searchText.value,
      orders: [], // 添加您的排序逻辑
    );
    onSearch(searchDTO);
  }


  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  SearchDTO getSearchDTO(){
    SearchDTO searchDTO = SearchDTO(content: textEditingController.text);
    return searchDTO;
  }
}

import 'dart:ui';

import 'package:floor/floor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:hamster/widget/config_page/media_search_config_page.dart';
import 'package:hamster/widget/custom_widget/card_flying_widget.dart';
import 'package:hamster/widget/list_page/relation_page_list_page.dart';
import 'package:hamster/widget/list_page/tag_page_list_page.dart';
import '../../tag_manage/model/dto/search_dto.dart';
import '../../tag_manage/model/po/tag_info.dart';
import '../../tag_manage/tag_manage_service.dart';
import 'media_page_list_page.dart';

/// 首页：展示 标签列表 媒体列表 关联列表 并切换，有搜索框
class MediaHomePage extends StatefulWidget {
  @override
  _MediaHomePageState createState() => _MediaHomePageState();
}

class _MediaHomePageState extends State<MediaHomePage> {
  int _selectedIndex = 1;

  List<Widget> _widgetOptions = <Widget>[
    TagPageListPage(),
    MediaPageListPage(),
    RelationPageListPage(),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MediaSearchConfigPage(),
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
      // bottomNavigationBar: BottomNavigationBar(
      //   items: const <BottomNavigationBarItem>[
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.tag),
      //       label: '标签库',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.movie),
      //       label: '媒体库',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.link),
      //       label: '关联库',
      //     ),
      //   ],
      //   currentIndex: _selectedIndex,
      //   selectedItemColor: Colors.blue,
      //   onTap: _onItemTapped,
      // ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          _buildBottomNavigationBarItem(
            icon: Icons.tag,
            label: '标签库',
            index: 0,
          ),
          _buildBottomNavigationBarItem(
            icon: Icons.movie,
            label: '媒体库',
            index: 1,
          ),
          _buildBottomNavigationBarItem(
            icon: Icons.link,
            label: '关联库',
            index: 2,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }

  BottomNavigationBarItem _buildBottomNavigationBarItem(
      {required IconData icon, required String label, required int index}) {
    return BottomNavigationBarItem(
      icon: GestureDetector(
        onLongPress: () {
          _onItemLongPressed(index);
        },
        child: Icon(icon),
      ),
      label: label,
    );
  }

  void _onItemLongPressed(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CardFlyingPage(),
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
    searchController =
        Get.put(CustomSearchController(onSearch: _handleSearch)); // 初始化并放置控制器
  }

  @override
  void dispose() {
    searchController.dispose(); // 清理搜索控制器
    super.dispose();
  }

  void _handleSearch(SearchDTO searchDTO) {
    // 标签库
    if (_selectedIndex == 0) {
      TagPagingController tagPagingController = Get.find<TagPagingController>();
      tagPagingController.refreshDataNotScan();
    }
    // 媒体库
    if (_selectedIndex == 1) {
      MediaPagingController controller = Get.find<MediaPagingController>();
      // 刷新数据
      controller.refreshDataNotScan();
    }
    // 关连库
    if (_selectedIndex == 2) {
      RelationPagingController relationPagingController =
          Get.find<RelationPagingController>();
      relationPagingController.refreshDataNotScan();
    }
  }
}

class SearchWidget extends StatelessWidget {
  final Function(SearchDTO) onSearch; // 回调函数，用于传递搜索条件

  const SearchWidget({Key? key, required this.onSearch}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final CustomSearchController controller = Get.put(CustomSearchController(onSearch: onSearch)); // 初始化并放置控制器
    final CustomSearchController controller =
        Get.find<CustomSearchController>();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Obx(() {
        return Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
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
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
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
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.blue),
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
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
            // InkWell(
            //   onTap: () {
            //     controller.convertDrawerState();
            //   },
            //   child: Icon(
            //     controller.getDrawerState()
            //         ? Icons.keyboard_arrow_up
            //         : Icons.keyboard_arrow_down,
            //     size: 15,
            //   ),
            // ),
            // if (controller.getDrawerState())
            //   Visibility(
            //     visible: controller.getDrawerState(),
            //     child: Column(
            //       children: [
            //         SizedBox(height: 10),
            //         Container(
            //           height: 30, // 控制Container的高度
            //           padding: EdgeInsets.symmetric(horizontal: 8),
            //           decoration: BoxDecoration(
            //             borderRadius: BorderRadius.circular(5),
            //             border: Border.all(color: Colors.grey),
            //           ),
            //           child: Wrap(
            //             spacing: 2, // 标签之间的间距
            //             children: controller.selectedItems
            //                 .map((item) => Row(
            //                       mainAxisSize: MainAxisSize.min,
            //                       children: [
            //                         Text(item.tagName ?? ''),
            //                         IconButton(
            //                           icon: Icon(Icons.clear),
            //                           onPressed: () {
            //                             controller.selectedItems.remove(item);
            //                           },
            //                         ),
            //                       ],
            //                     ))
            //                 .toList(),
            //           ),
            //         ),
            //         // Expanded( // 使用Expanded确保子组件填满剩余空间
            //         // child: Column(
            //         //   crossAxisAlignment: CrossAxisAlignment.stretch,
            //         //   children: [
            //         TextFormField(
            //           controller: controller.tagSearchController,
            //           onChanged: (value) {
            //             controller.updateTagSearchText(value);
            //             controller.searchTagItems(value);
            //           },
            //           decoration: InputDecoration(
            //             hintText: '标签搜索...',
            //             prefixIcon: Icon(Icons.search),
            //             border: OutlineInputBorder(
            //               borderRadius: BorderRadius.circular(10.0),
            //               borderSide: BorderSide(color: Colors.grey),
            //             ),
            //             focusedBorder: OutlineInputBorder(
            //               borderRadius: BorderRadius.circular(10.0),
            //               borderSide: BorderSide(color: Colors.blue),
            //             ),
            //             contentPadding: EdgeInsets.symmetric(
            //                 vertical: 8.0, horizontal: 10.0),
            //           ),
            //         ),
            //         SizedBox(height: 5),
            //         if (controller.dropdownItems.isNotEmpty)
            //           Expanded(
            //             child: ListView.builder(
            //               itemCount: controller.dropdownItems.length,
            //               itemBuilder: (context, index) {
            //                 final item = controller.dropdownItems[index];
            //                 return ListTile(
            //                   title: Text(item.tagName ?? ''),
            //                   onTap: () {
            //                     // 处理选项点击事件
            //                     controller.selectedItems.add(item);
            //                   },
            //                 );
            //               },
            //             ),
            //           ),
            //       ],
            //       // ),
            //       // ),
            //       // ],
            //     ),
            //   ),
          ],
        );
      }),
    );
  }
}

class CustomSearchController extends GetxController {
  RxBool _isDrawerOpen = false.obs;
  RxString searchText = ''.obs; // 使用 RxString 来存储搜索文本
  RxString tagSearchText = ''.obs;
  RxList<TagInfo> dropdownItems = <TagInfo>[].obs; // 添加下拉框选项
  RxList<TagInfo> selectedItems = <TagInfo>[].obs;
  final TextEditingController textEditingController =
      TextEditingController(); // 添加TextEditingController
  final TextEditingController tagSearchController = TextEditingController();

  final Function(SearchDTO) onSearch; // 添加回调函数

  CustomSearchController({required this.onSearch}) {
    textEditingController.addListener(_onTextChanged);
    textEditingController.addListener(_onTagSearchTextChanged);
  }

  void convertDrawerState() {
    _isDrawerOpen.value = !_isDrawerOpen.value;
  }

  bool getDrawerState() {
    return _isDrawerOpen.value;
  }

  void _onTextChanged() {
    searchText.value = textEditingController.text;
  }

  void _onTagSearchTextChanged() {
    tagSearchText.value = tagSearchController.text;
  }

  void updateSearchText(String value) {
    textEditingController.text = value;
    searchText.value = value;
  }

  void updateTagSearchText(String value) {
    tagSearchController.text = value;
    tagSearchText.value = value;
  }

  Future<void> searchTagItems(String value) async {
    List<TagInfo> tagList = await searchTagInfoListByTagName(value);
    dropdownItems.value = tagList;
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

  SearchDTO getSearchDTO() {
    SearchDTO searchDTO = SearchDTO(content: textEditingController.text);
    return searchDTO;
  }
}

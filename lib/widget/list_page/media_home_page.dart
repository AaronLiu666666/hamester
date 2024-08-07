import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hamster/widget/config_page/config_page.dart';
import 'package:hamster/widget/config_page/media_search_config_page.dart';
import 'package:hamster/widget/list_page/media_card_flying_page.dart';
import 'package:hamster/widget/list_page/relation_card_flying_page.dart';
import 'package:hamster/widget/list_page/relation_page_list_page.dart';
import 'package:hamster/widget/list_page/tag_card_flying_page.dart';
import 'package:hamster/widget/list_page/tag_page_list_page.dart';

import '../../tag_manage/model/dto/search_dto.dart';
import '../../tag_manage/model/po/tag_info.dart';
import '../../tag_manage/tag_manage_service.dart';
import '../bruno/bruno_test.dart';
import 'media_page_list_page.dart';

/// 首页：展示 标签列表 媒体列表 关联列表 并切换，有搜索框
class MediaHomePage extends StatefulWidget {
  const MediaHomePage({super.key});

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
        preferredSize: const Size.fromHeight(0), // 设置高度为0
        child: AppBar(
          backgroundColor: Colors.transparent, // 设置背景色为透明
          elevation: 0,
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Expanded(
              child: Container(),
              // child: ListView(
              //   children: <Widget>[
              //     ListTile(
              //       title: const Text('媒体文件扫描目录'),
              //       onTap: () {
              //         Navigator.push(
              //           context,
              //           MaterialPageRoute(
              //             builder: (context) => MediaSearchConfigPage(),
              //           ),
              //         );
              //       },
              //     ),
              //   ],
              // ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      // 执行某些操作
                      Get.to(()=>const ConfigPage());
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Colors.grey,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.settings, color: Colors.white),
                        ),
                        const SizedBox(height: 8), // 间隔
                        const Text('设置'),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        )
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
          // BrunoTest(),
          Expanded(
            child: _widgetOptions.elementAt(_selectedIndex),
          ),
        ],
      ),
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
    // 注意：Getx的组件跳转要用Get.to如果不用可能导致Getx控制器不会被正常销毁
    if (index == 0) {
      Get.to(
        () => TagCardFlyingPage(),
      );
    }
    if (index == 1) {
      Get.to(
        () => MediaCardFlyingPage(),
      );
    }
    if (index == 2) {
      Get.to(
        () => RelationCardFlyingPage(),
      );
    }
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

  import 'package:flutter/cupertino.dart';
  import 'package:flutter/material.dart';

  import '../../tag_manage/model/dto/search_dto.dart';
  import 'media_list_page.dart';
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
      MediaListPage(),
      MediaTagRelationListPage(),
    ];

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Media Home Page'),
        ),
        // body: Column(
        //   crossAxisAlignment: CrossAxisAlignment.stretch,
        //   children: [
        //     SearchWidget(
        //       onSearch: _handleSearch,
        //     ),
        //     // Padding(
        //     //   padding: const EdgeInsets.all(8.0),
        //     //   child:
        //     //   TextField(
        //     //     decoration: InputDecoration(
        //     //       hintText: 'Search...',
        //     //       prefixIcon: Icon(Icons.search),
        //     //       border: OutlineInputBorder(),
        //     //     ),
        //     //   ),
        //     // ),
        //     Expanded(
        //       child: _widgetOptions.elementAt(_selectedIndex),
        //     ),
        //     ButtonBar(
        //       alignment: MainAxisAlignment.spaceEvenly,
        //       children: [
        //         ElevatedButton(
        //           onPressed: () {
        //             _onItemTapped(0);
        //           },
        //           child: Text('标签库'),
        //         ),
        //         ElevatedButton(
        //           onPressed: () {
        //             _onItemTapped(1);
        //           },
        //           child: Text('媒体库'),
        //         ),
        //         ElevatedButton(
        //           onPressed: () {
        //             _onItemTapped(2);
        //           },
        //           child: Text('关联库'),
        //         ),
        //       ],
        //     ),
        //   ],
        // ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SearchWidget(
                onSearch: _handleSearch,
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

    void _handleSearch(SearchDTO searchDTO) {
      // 处理搜索条件的逻辑，例如更新页面内容
      // 在这里可以调用 setState 更新页面或者执行其他操作
      print('Received search DTO: $searchDTO');
    }
  }

  class SearchWidget extends StatefulWidget {

    final Function(SearchDTO) onSearch; // 回调函数，用于传递搜索条件

    const SearchWidget({Key? key, required this.onSearch}) : super(key: key);

    @override
    _SearchWidgetState createState() => _SearchWidgetState();
  }



  class _SearchWidgetState extends State<SearchWidget> {
    String? _searchText; // 搜索框文本
    Set<String> _selectedFields = {}; // 选中的排序字段
    Map<String, bool> _orderTypes = {}; // 排序类型与方向的映射

    List<String> _fields = ['Field 1', 'Field 2', 'Field 3']; // 排序字段列表

    @override
    Widget build(BuildContext context) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            // 搜索框 自适应
            Expanded(
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchText = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: '',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(width: 10),
            // 下拉框
            DropdownButton<String>(
              // 下拉框不下拉时显示第一个搜索内容
              value: _fields.isNotEmpty ? _fields.first : null,
              onChanged: (String? newValue) {
                setState(() {
                  if (_selectedFields.contains(newValue)) {
                    _selectedFields.remove(newValue);
                  } else {
                    _selectedFields.add(newValue!);
                  }
                  _toggleOrderType(newValue!); // 更新排序类型
                });
              },
              items: _fields.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Text(
                          value,
                          style: TextStyle(
                            // 如果选择了该排序规则则显示蓝色，否则显示默认颜色黑色
                            color: _selectedFields.contains(value) ? Colors.blue : null,
                          ),
                        ),
                        SizedBox(width: 10),
                        _buildArrowIcon(value),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                // 构建搜索条件对象
                SearchDTO searchDTO = SearchDTO(
                  content: _searchText,
                  orders: _selectedFields.isNotEmpty
                      ? _selectedFields.map((field) {
                    return SearchOrder(
                      field: field,
                      orderType: _orderTypes[field]! ? 'Ascending' : 'Descending',
                    );
                  }).toList()
                      : null,
                );
                // 调用回调函数传递搜索条件
                widget.onSearch(searchDTO);
              },
              child: Text('Search'),
            ),
          ],
        ),
      );
    }

    // Widget _buildArrowIcon(String field) {
    //   return IconButton(
    //     icon: _orderTypes.containsKey(field)
    //         ? _orderTypes[field]!
    //         ? Icon(Icons.arrow_upward)
    //         : Icon(Icons.arrow_downward)
    //         : Icon(Icons.arrow_downward),
    //     onPressed: () {
    //       print('Arrow clicked for field: $field');
    //       setState(() {
    //         _toggleOrderType(field);
    //         _updateArrowIcons();
    //       });
    //     },
    //   );
    // }
    //
    //
    // void _toggleOrderType(String field) {
    //   if (_orderTypes.containsKey(field)) {
    //     _orderTypes[field] = !_orderTypes[field]!;
    //   } else {
    //     _orderTypes[field] = true;
    //   }
    // }
    //
    // void _updateArrowIcons() {
    //   setState(() {}); // 触发重新构建以更新箭头图标
    // }
    Widget _buildArrowIcon(String field) {
      bool? orderType = _orderTypes[field];
      if (orderType == null) {
        orderType = false; // 默认降序
        _orderTypes[field] = orderType;
      }

      return IconButton(
        icon: orderType ? Icon(Icons.arrow_upward) : Icon(Icons.arrow_downward),
        onPressed: () {
          print('Arrow clicked for field: $field');
          setState(() {
            _orderTypes[field] = !_orderTypes[field]!;
          });
        },
      );
    }

    void _toggleOrderType(String field) {
      if (!_orderTypes.containsKey(field)) {
        _orderTypes[field] = false; // 默认降序
      }
    }

  }


import 'package:flutter/material.dart';
import 'media_search_config_page.dart';

class ConfigPage extends StatelessWidget {
  const ConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '设置',
          style: TextStyle(fontSize: 18),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios), // 使用类似于 "<" 的箭头图标
          onPressed: () {
            Navigator.of(context).pop(); // 返回到上一页
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: <Widget>[
          _buildGroupedRows(
            context,
            [
              _buildRow(
                context,
                '媒体文件扫描目录',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MediaSearchConfigPage(),
                    ),
                  );
                },
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Divider(height: 0, color: Colors.blueGrey),
              ),
              _buildRow(
                context,
                '视频封面设置',
                () {
                  // 执行某些操作
                },
              ),
            ],
          ),
          const SizedBox(height: 15), // 加大空隙
          _buildGroupedRows(context, [
            _buildRow(
              context,
              '关于 hamster',
              () {},
            ),
          ])
        ],
      ),
    );
  }

  // Widget _buildRow(
  //     BuildContext context, String title, VoidCallback onTap) {
  //   return GestureDetector(
  //     onTap: onTap,
  //     child: Container(
  //       height: 40.0, // 设置行的高度
  //       padding: const EdgeInsets.symmetric(horizontal: 16.0),
  //       decoration: const BoxDecoration(
  //         color: Colors.grey,
  //       ),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           Text(
  //             title,
  //             style: const TextStyle(fontSize: 16),
  //           ),
  //           const Icon(Icons.chevron_right),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildRow(
      BuildContext context, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Material(
        color: Colors.grey,
        // InkWell 添加点击水波纹动效
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 40.0, // 设置行的高度
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildGroupedRows(BuildContext context, List<Widget> tiles) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Column(
        children: tiles,
      ),
    );
  }
}

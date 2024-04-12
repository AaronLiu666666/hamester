import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class MediaSearchConfigPage extends StatefulWidget {
  @override
  _MediaSearchConfigPageState createState() => _MediaSearchConfigPageState();
}

class _MediaSearchConfigPageState extends State<MediaSearchConfigPage> {
  List<String> _selectedFolders = []; // 存储已选择的文件夹路径

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('媒体文件扫描路径配置'),
      ),
      body: ListView.builder(
        itemCount: _selectedFolders.length,
        itemBuilder: (context, index) {
          final folderPath = _selectedFolders[index];
          return ListTile(
            title: Text(folderPath),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                // 删除选中的文件夹
                setState(() {
                  _selectedFolders.removeAt(index);
                });
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickFolder,
        tooltip: '添加文件夹',
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: _saveSelectedFolders,
                child: Text('保存'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 选择文件夹
  void _pickFolder() async {
    // 这里调用文件管理器或者文件选择插件选择文件夹
    // 假设已经选择了文件夹路径，可以替换为实际的文件选择逻辑
    String? folderPath = await _selectFolder(); // 替换为实际的选择文件夹逻辑
    if (folderPath != null) {
      setState(() {
        _selectedFolders.add(folderPath);
      });
    }
  }

  // 使用file_picker选择文件夹
  Future<String?> _selectFolder() async {
    try {
      // 使用file_picker选择文件夹
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      return selectedDirectory;
    } catch (e) {
      print('选择文件夹失败 $e');
      return null;
    }
  }

  // 保存已选文件夹
  void _saveSelectedFolders() {
    // 这里执行保存操作，可以将selectedFolders保存到本地或执行其他逻辑
    print('已保存的文件夹路径：$_selectedFolders');
  }
}

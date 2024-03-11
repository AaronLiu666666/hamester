import 'package:flutter/material.dart';
import 'package:hamster/media_manage/service/media_manager_service.dart';

class DebugWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // 处理按钮点击事件
        MediaManageService mediaManageService = MediaManageService();
        mediaManageService.initMediaFileData();
      },
      child: Text('Click Me'),
    );
  }

}
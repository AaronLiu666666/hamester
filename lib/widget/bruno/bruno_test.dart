import 'package:bruno/bruno.dart';
import 'package:flutter/cupertino.dart';

class BrunoTest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BrnAppBar(
      //默认显示返回按钮
      automaticallyImplyLeading: true,
      title: '名称名称',
      //自定义的右侧文本
      actions: BrnTextAction(
        '文本按钮',
        //设置为深色背景，则显示白色
        themeData: BrnAppBarConfig.dark(),
      ),
    );
  }
}

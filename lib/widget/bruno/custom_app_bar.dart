
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Icon(Icons.menu),
      title: SearchBar(
        leading: Icon(Icons.search),
        hintText: "请输入搜索内容...",
      ),
      actions: [
        TextButton(onPressed: (){}, child: Text("搜索"))
      ],
    );
  }

}
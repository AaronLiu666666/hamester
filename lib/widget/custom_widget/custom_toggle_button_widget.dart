
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 自定义 内容切换按钮
class CustomToggleButtons extends StatefulWidget {
  final List<String> labels;
  final List<bool> isSelected;
  final Function(int) onPressed;

  const CustomToggleButtons({
    required this.labels,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  _CustomToggleButtonsState createState() => _CustomToggleButtonsState();
}

class _CustomToggleButtonsState extends State<CustomToggleButtons> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 10, // 按钮之间的水平间距
        children: List.generate(widget.labels.length, (index) {
          return GestureDetector(
            onTap: () {
              widget.onPressed(index);
            },
            child: Container(
              width: 100, // 设置按钮宽度
              height: 40, // 设置按钮高度
              decoration: BoxDecoration(
                color: widget.isSelected[index] ? Colors.blue : Colors.transparent, // 非选中状态透明
                border: Border.all(color: Colors.grey), // 添加边框
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                widget.labels[index],
                style: TextStyle(
                  color: widget.isSelected[index] ? Colors.white : Colors.black,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

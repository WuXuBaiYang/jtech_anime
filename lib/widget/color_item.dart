import 'package:flutter/material.dart';

/*
* 颜色选择器Item组件
* @author wuxubaiyang
* @Time 2023/11/27 15:27
*/
class ColorPickerItem extends StatelessWidget {
  // 色值
  final Color color;

  // 大小
  final double size;

  // 内间距
  final EdgeInsetsGeometry padding;

  // 点击事件
  final VoidCallback? onPressed;

  // 是否已选中
  final bool isSelected;

  // 自定义tooltip
  final String? tooltip;

  const ColorPickerItem({
    super.key,
    required this.color,
    this.tooltip,
    this.size = 45,
    this.onPressed,
    this.isSelected = false,
    this.padding = const EdgeInsets.all(4),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: Size.square(size),
      child: _buildItem(color),
    );
  }

  // 构建子项
  Widget _buildItem(Color color) {
    if (isSelected) {
      return IconButton.outlined(
        tooltip: tooltip,
        padding: padding,
        onPressed: onPressed,
        icon: _buildItemSub(color),
      );
    }
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      icon: _buildItemSub(color),
    );
  }

  // 构建子项sub
  Widget _buildItemSub(Color color) {
    return CircleAvatar(
      backgroundColor: color,
    );
  }
}

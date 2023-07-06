import 'package:flutter/material.dart';

/*
* 带标题结构组件
* @author wuxubaiyang
* @Time 2022/12/28 11:10
*/
class InfoLabel extends StatelessWidget {
  // 图标
  final Widget? icon;

  // 标题
  final Widget label;

  // 子元素
  final Widget child;

  // 元素间距
  final double spaceSize;

  // 子元素是否展开
  final bool childExpanded;

  const InfoLabel({
    super.key,
    required this.label,
    required this.child,
    this.childExpanded = false,
    this.spaceSize = 14,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [icon ?? const SizedBox(), label]),
        SizedBox(height: spaceSize),
        if (childExpanded) Expanded(child: child) else child
      ],
    );
  }
}

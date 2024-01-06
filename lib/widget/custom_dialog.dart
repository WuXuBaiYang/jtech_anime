import 'package:flutter/material.dart';

/*
* 自定义弹窗
* @author wuxubaiyang
* @Time 2023/12/3 19:45
*/
class CustomDialog extends StatelessWidget {
  // 标题
  final Widget? title;

  // 内容元素
  final Widget content;

  // 约束
  final BoxConstraints constraints;

  // 动作按钮集合
  final List<Widget>? actions;

  // 是否可滚动
  final bool scrollable;

  const CustomDialog({
    super.key,
    this.title,
    required this.content,
    this.actions,
    this.scrollable = false,
    this.constraints = const BoxConstraints.tightFor(width: 280),
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: title,
      actions: actions,
      scrollable: scrollable,
      content: ConstrainedBox(
        constraints: constraints,
        child: content,
      ),
    );
  }
}

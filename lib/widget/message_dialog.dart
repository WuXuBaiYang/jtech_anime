import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/*
* 消息弹窗
* @author wuxubaiyang
* @Time 2023/3/13 17:14
*/
class MessageDialog extends StatelessWidget {
  // 左侧按钮
  final Widget? actionLeft;

  // 中间按钮
  final Widget? actionMiddle;

  // 右侧按钮
  final Widget? actionRight;

  // 标题
  final Widget? title;

  // 内容
  final Widget? content;

  const MessageDialog({
    super.key,
    this.actionLeft,
    this.actionMiddle,
    this.actionRight,
    this.title,
    this.content,
  });

  static Future<V?> show<V>(
    BuildContext context, {
    Widget? actionLeft,
    Widget? actionMiddle,
    Widget? actionRight,
    Widget? title,
    Widget? content,
    bool barrierDismissible = true,
  }) {
    return showCupertinoDialog<V>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) => MessageDialog(
        actionLeft: actionLeft,
        actionMiddle: actionMiddle,
        actionRight: actionRight,
        title: title,
        content: content,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: title,
      content: content,
      actions: _dialogActions,
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actionsPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  // 弹窗动作条
  List<Widget> get _dialogActions => [
        actionLeft ?? const SizedBox(),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            actionMiddle ?? const SizedBox(),
            actionRight ?? const SizedBox(),
          ],
        )
      ];
}

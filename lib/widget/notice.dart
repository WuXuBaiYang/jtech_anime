import 'package:flutter/material.dart';

/*
* 自定义消息模板
* @author wuxubaiyang
* @Time 2023/12/14 14:34
*/
class CustomNoticeView extends StatelessWidget {
  // 消息图标
  final Widget? icon;

  // 主题色
  final Color? color;

  // 标题
  final Widget? title;

  // 消息
  final Widget content;

  // 动作按钮（只允许一个）
  final Widget? action;

  // 尺寸约束
  final BoxConstraints constraints;

  // 内间距
  final EdgeInsetsGeometry padding;

  // 成功消息样式
  CustomNoticeView.success(
    BuildContext context, {
    Key? key,
    required String message,
    Color? color,
    String? title,
    Widget? action,
    BoxConstraints? constraints,
    EdgeInsetsGeometry? padding,
  }) : this(
          key: key,
          color: color,
          action: action,
          padding: padding,
          content: Text(message),
          constraints: constraints,
          title: title != null ? Text(title) : null,
          icon: const Icon(Icons.check_circle, color: Colors.greenAccent),
        );

  // 失败消息样式
  CustomNoticeView.error(
    BuildContext context, {
    Key? key,
    required String message,
    Color? color,
    String? title,
    Widget? action,
    BoxConstraints? constraints,
    EdgeInsetsGeometry? padding,
  }) : this(
          key: key,
          color: color,
          action: action,
          padding: padding,
          content: Text(message),
          constraints: constraints,
          title: title != null ? Text(title) : null,
          icon: const Icon(Icons.error, color: Colors.redAccent),
        );

  // 帮助消息样式
  CustomNoticeView.help(
    BuildContext context, {
    Key? key,
    required String message,
    Color? color,
    String? title,
    Widget? action,
    BoxConstraints? constraints,
    EdgeInsetsGeometry? padding,
  }) : this(
          key: key,
          color: color,
          action: action,
          padding: padding,
          content: Text(message),
          constraints: constraints,
          title: title != null ? Text(title) : null,
          icon: const Icon(Icons.help, color: Colors.blueAccent),
        );

  // 自定义样式
  const CustomNoticeView({
    super.key,
    required this.content,
    this.icon,
    this.color,
    this.title,
    this.action,
    BoxConstraints? constraints,
    EdgeInsetsGeometry? padding,
  })  : padding = const EdgeInsets.all(14),
        constraints = const BoxConstraints(
            minHeight: 65, minWidth: 180, maxHeight: 120, maxWidth: 340);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      elevation: 6,
      child: Container(
        padding: padding,
        constraints: constraints,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[
            icon ?? const SizedBox(),
            const SizedBox(width: 14),
          ],
          Expanded(child: _buildContent(context)),
          if (action != null) ...[
            const SizedBox(width: 8),
            action ?? const SizedBox(),
          ],
        ]),
      ),
    );
  }

  // 构建消息内容
  Widget _buildContent(BuildContext context) {
    final hasTitle = title != null;
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DefaultTextStyle(
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium ?? const TextStyle(),
          child: title ?? const SizedBox(),
        ),
        if (hasTitle) const SizedBox(height: 4),
        DefaultTextStyle(
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: (theme.textTheme.bodyMedium ?? const TextStyle())
              .copyWith(color: hasTitle ? Colors.grey : null),
          child: content,
        ),
      ],
    );
  }
}

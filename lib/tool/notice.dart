import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:jtech_anime/widget/notice.dart';

/*
* 消息通知工具
* @author wuxubaiyang
* @Time 2023/12/13 10:43
*/
class NoticeTool {
  // 展示成功消息
  static void success(
    BuildContext context, {
    required String message,
    EdgeInsetsGeometry? padding,
    BoxConstraints? constraints,
    Duration? duration,
    Widget? action,
    String? title,
    Color? color,
  }) {
    return _show(
      context,
      duration: duration,
      builder: (_) => CustomNoticeView.success(
        context,
        color: color,
        title: title,
        action: action,
        message: message,
        padding: padding,
        constraints: constraints,
      ),
    );
  }

  // 展示错误消息
  static void error(
    BuildContext context, {
    required String message,
    EdgeInsetsGeometry? padding,
    BoxConstraints? constraints,
    Duration? duration,
    Widget? action,
    String? title,
    Color? color,
  }) {
    return _show(
      context,
      duration: duration,
      builder: (_) => CustomNoticeView.error(
        context,
        color: color,
        title: title,
        action: action,
        message: message,
        padding: padding,
        constraints: constraints,
      ),
    );
  }

  // 帮助消息样式
  static void help(
    BuildContext context, {
    required String message,
    EdgeInsetsGeometry? padding,
    BoxConstraints? constraints,
    Duration? duration,
    Widget? action,
    String? title,
    Color? color,
  }) {
    return _show(
      context,
      duration: duration,
      builder: (_) => CustomNoticeView.help(
        context,
        color: color,
        title: title,
        action: action,
        message: message,
        padding: padding,
        constraints: constraints,
      ),
    );
  }

  // 展示自定义消息
  static void custom(
    BuildContext context, {
    required Widget content,
    EdgeInsetsGeometry? padding,
    BoxConstraints? constraints,
    Duration? duration,
    Widget? action,
    Widget? title,
    Widget? icon,
    Color? color,
  }) {
    return _show(
      context,
      duration: duration,
      builder: (_) => CustomNoticeView(
        icon: icon,
        color: color,
        title: title,
        action: action,
        padding: padding,
        content: content,
        constraints: constraints,
      ),
    );
  }

  // 展示消息
  static void _show(
    BuildContext context, {
    required WidgetBuilder builder,
    Duration? duration,
  }) {
    return AnimatedSnackBar(
      builder: builder,
      animationDuration: const Duration(milliseconds: 200),
      snackBarStrategy: const ColumnSnackBarStrategy(gap: 4),
      duration: duration ?? const Duration(milliseconds: 2000),
      desktopSnackBarPosition: DesktopSnackBarPosition.topCenter,
    ).show(context);
  }
}

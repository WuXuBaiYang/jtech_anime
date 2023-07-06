import 'package:flutter/material.dart';

/*
* snack消息提示工具方法
* @author wuxubaiyang
* @Time 2022/3/18 15:34
*/
class SnackTool {
  // 展示snack提示
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> show(
    BuildContext context, {
    required Widget child,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    ShapeBorder? shape,
    Duration? duration,
    bool? fixed,
    Color? backgroundColor,
    SnackBarAction? action,
    // 悬浮参数
    double? elevation,
    double? width,
  }) {
    // 默认值
    fixed ??= true;
    duration ??= const Duration(milliseconds: 4000);
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: child,
      margin: margin,
      padding: padding,
      shape: shape,
      duration: duration,
      backgroundColor: backgroundColor,
      behavior: fixed ? SnackBarBehavior.fixed : SnackBarBehavior.floating,
      elevation: elevation,
      width: width,
      action: action,
    ));
  }

  // 展示常驻snack提示
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showConst(
    BuildContext context, {
    required Widget child,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    ShapeBorder? shape,
    bool? fixed,
    Color? backgroundColor,
    SnackBarAction? action,
    // 悬浮参数
    double? elevation,
    double? width,
  }) =>
      show(context,
          child: child,
          duration: const Duration(days: 1),
          margin: margin,
          padding: padding,
          shape: shape,
          fixed: fixed,
          backgroundColor: backgroundColor,
          action: action,
          elevation: elevation,
          width: width);

  // 展示基础的文本snack提示
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showMessage(
    BuildContext context, {
    required String message,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    ShapeBorder? shape,
    Duration? duration,
    bool? fixed,
    Color? backgroundColor,
    SnackBarAction? action,
    // 悬浮参数
    double? elevation,
    double? width,
  }) =>
      show(context,
          child: Text(message),
          duration: duration,
          margin: margin,
          padding: padding,
          shape: shape,
          fixed: fixed,
          backgroundColor: backgroundColor,
          action: action,
          elevation: elevation,
          width: width);
}

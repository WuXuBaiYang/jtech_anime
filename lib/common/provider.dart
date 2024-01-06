import 'package:flutter/material.dart';
import 'package:jtech_anime/tool/notice.dart';

/*
* 代理基类
* @author wuxubaiyang
* @Time 2023/11/24 11:14
*/
abstract class BaseProvider extends ChangeNotifier {
  // context
  final BuildContext context;

  BaseProvider(this.context);

  // 展示成功消息
  void showSuccess(String message, {String? title}) =>
      NoticeTool.success(context, message: message, title: title);

  // 展示错误消息
  void showError(String message, {String? title}) =>
      NoticeTool.error(context, message: message, title: title);

  // 展示消息提醒
  void showHelp(String message, {String? title}) =>
      NoticeTool.help(context, message: message, title: title);
}

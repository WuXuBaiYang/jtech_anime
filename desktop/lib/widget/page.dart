import 'package:flutter/material.dart';
import 'package:jtech_anime/common/common.dart';
import 'package:window_manager/window_manager.dart';

/*
* 窗口页面
* @author wuxubaiyang
* @Time 2023/9/5 17:21
*/
class WindowPage extends StatelessWidget {
  // 子元素
  final Widget child;

  // 标题
  final Widget? title;

  // 前置
  final Widget? leading;

  // 动作按钮（接在默认操作按钮左边）
  final List<Widget> actions;

  const WindowPage({
    super.key,
    required this.child,
    this.title,
    this.leading,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: _buildStatusBar(),
      ),
      body: child,
    );
  }

  // 构建状态条
  Widget _buildStatusBar() {
    return DragToMoveArea(
      child: AppBar(
        leading: leading,
        actions: [...actions, ..._defaultActions],
        title: title ?? const Text(Common.appName),
      ),
    );
  }

  // 默认操作按钮（最小化/最大化/关闭）
  List<Widget> get _defaultActions => [];
}

import 'package:desktop/common/theme.dart';
import 'package:flutter/material.dart';
import 'package:jtech_anime_base/base.dart';
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

  // 侧边栏
  final Widget? sideBar;

  // 全屏状态
  final maximized = ValueChangeNotifier<bool>(false);

  WindowPage({
    super.key,
    required this.child,
    this.title,
    this.leading,
    this.sideBar,
    this.actions = const [],
  }) {
    // 获取当前全屏状态
    windowManager.isMaximized().then(maximized.setValue);
    // 监听全屏状态
    maximized.addListener(() => maximized.value
        ? windowManager.maximize()
        : windowManager.unmaximize());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          if (sideBar != null) ...[sideBar!, const VerticalDivider()],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PreferredSize(
                  preferredSize: const Size.fromHeight(kToolbarHeightCustom),
                  child: _buildStatusBar(),
                ),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 构建状态条
  Widget _buildStatusBar() {
    return DragToMoveArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            if (leading != null) leading!,
            if (title != null) title!,
            const Spacer(),
            ...actions,
            ...windowCaptions,
          ].expand<Widget>((child) {
            return [child, const SizedBox(width: 4)];
          }).toList(),
        ),
      ),
    );
  }

  // 窗口交互按钮集合
  List<Widget> get windowCaptions => [
        // 最小化按钮
        IconButton(
          icon: const Icon(FontAwesomeIcons.windowMinimize),
          onPressed: () => windowManager.isMinimized().then((isMinimized) =>
              isMinimized ? windowManager.restore() : windowManager.minimize()),
        ),
        // 最大化按钮
        ValueListenableBuilder<bool>(
          valueListenable: maximized,
          builder: (_, isMaximized, __) {
            return IconButton(
              icon: Icon(isMaximized
                  ? FontAwesomeIcons.windowRestore
                  : FontAwesomeIcons.windowMaximize),
              onPressed: () => maximized.setValue(!isMaximized),
            );
          },
        ),
        // 关闭按钮
        IconButton(
          onPressed: windowManager.close,
          hoverColor: kPrimaryColor.withOpacity(0.12),
          highlightColor: kPrimaryColor.withOpacity(0.2),
          icon: const Icon(FontAwesomeIcons.rectangleXmark),
        ),
      ];
}

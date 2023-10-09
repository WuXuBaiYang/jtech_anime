import 'package:desktop/common/theme.dart';
import 'package:desktop/tool/version.dart';
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

  // 是否全屏
  final bool isFullScreen;

  // 窗口最大化状态
  final maximized = ValueChangeNotifier<bool>(false);

  WindowPage({
    super.key,
    required this.child,
    this.title,
    this.leading,
    this.sideBar,
    this.actions = const [],
    this.isFullScreen = false,
  }) {
    // 获取当前最大化状态
    windowManager.isMaximized().then(maximized.setValue);
    // 监听最大化状态
    maximized.addListener(() => maximized.value
        ? windowManager.maximize()
        : windowManager.unmaximize());
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: _buildWindowPage(context)),
        StreamBuilder<double>(
          stream: AppVersionTool.downloadProgressStream,
          builder: (_, snap) {
            final value = snap.data ?? 0;
            return LinearProgressIndicator(value: value);
          },
        ),
      ],
    );
  }

  // 构建窗口页面
  Widget _buildWindowPage(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          if (sideBar != null && !isFullScreen) ...[
            sideBar!,
            const VerticalDivider()
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!isFullScreen)
                  PreferredSize(
                    preferredSize: const Size.fromHeight(kToolbarHeightCustom),
                    child: _buildStatusBar(context),
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
  Widget _buildStatusBar(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        iconButtonTheme: const IconButtonThemeData(
          style: ButtonStyle(
            iconSize: MaterialStatePropertyAll(14),
            padding: MaterialStatePropertyAll(EdgeInsets.all(10)),
            minimumSize: MaterialStatePropertyAll(Size.square(30)),
          ),
        ),
      ),
      child: DragToMoveArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              const SizedBox(width: 2),
              if (leading != null) leading!,
              if (title != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: title!,
                ),
              const Spacer(),
              ...actions,
              const SizedBox(width: 14),
              ...windowCaptions,
            ].expand<Widget>((child) {
              return [child, const SizedBox(width: 4)];
            }).toList(),
          ),
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

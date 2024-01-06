import 'package:flutter/material.dart';
import 'package:jtech_anime/provider/window.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

/*
* 状态条
* @author wuxubaiyang
* @Time 2023/12/13 15:59
*/
class StatusBar extends StatelessWidget {
  // 动作按钮集合
  final List<Widget> actions;

  // 主题亮度
  final Brightness brightness;

  const StatusBar({
    super.key,
    this.actions = const [],
    this.brightness = Brightness.light,
  });

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: DragToMoveArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              if (actions.isEmpty) const Spacer(),
              ...actions,
              ClipRRect(
                clipBehavior: Clip.antiAlias,
                borderRadius: BorderRadius.circular(4),
                child: WindowCaptionButton.minimize(
                  brightness: brightness,
                  onPressed: windowManager.minimize,
                ),
              ),
              ClipRRect(
                clipBehavior: Clip.antiAlias,
                borderRadius: BorderRadius.circular(4),
                child: _buildMaximizeButton(brightness),
              ),
              ClipRRect(
                clipBehavior: Clip.antiAlias,
                borderRadius: BorderRadius.circular(4),
                child: WindowCaptionButton.close(
                  brightness: brightness,
                  onPressed: windowManager.close,
                ),
              ),
            ].expand<Widget>((child) {
              return [child, const SizedBox(width: 4)];
            }).toList(),
          ),
        ),
      ),
    );
  }

  // 构建窗口最大化按钮
  Widget _buildMaximizeButton(Brightness brightness) {
    return Selector<WindowProvider, bool>(
      selector: (_, provider) => provider.maximized,
      builder: (context, isMaximized, __) {
        if (isMaximized) {
          return WindowCaptionButton.unmaximize(
            brightness: brightness,
            onPressed: context.read<WindowProvider>().unMaximize,
          );
        }
        return WindowCaptionButton.maximize(
          brightness: brightness,
          onPressed: context.read<WindowProvider>().maximize,
        );
      },
    );
  }
}

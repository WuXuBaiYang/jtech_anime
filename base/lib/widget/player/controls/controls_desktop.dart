import 'package:jtech_anime_base/widget/listenable_builders.dart';
import 'package:jtech_anime_base/widget/player/widgets/brightness.dart';
import 'package:flutter/material.dart';
import 'bottom.dart';
import 'controls.dart';
import 'mini.dart';
import 'status.dart';
import 'top.dart';

/*
* 自定义播放器控制层-桌面端
* @author wuxubaiyang
* @Time 2023/11/7 9:51
*/
class DesktopCustomPlayerControls extends CustomPlayerControls {
  const DesktopCustomPlayerControls({
    super.key,
    required super.controller,
    super.theme,
    super.title,
    super.leading,
    super.subTitle,
    super.buffingSize,
    super.topActions,
    super.bottomActions,
  });

  @override
  State<StatefulWidget> createState() => _DesktopCustomPlayerControlsState();
}

/*
* 自定义播放器控制层-桌面端
* @author wuxubaiyang
* @Time 2023/11/6 16:54
*/
class _DesktopCustomPlayerControlsState extends State<CustomPlayerControls> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: widget.getTheme(context),
      child: _buildControls(),
    );
  }

  // 构建控制器
  Widget _buildControls() {
    final controller = widget.controller;
    return GestureDetector(
      onTap: () => widget.controller.resumeOrPause().then((playing) {
        if (playing) controller.setControlVisible(true);
      }),
      onDoubleTap: () => controller.toggleFullscreen(),
      child: MouseRegion(
        onHover: (_) => controller.setControlVisible(true),
        onEnter: (_) => controller.setControlVisible(true),
        onExit: (_) => controller.setControlVisible(false),
        child: Stack(
          children: [
            CustomPlayerBrightness(controller: widget.controller),
            _buildVisibleControls(),
            CustomPlayerControlsStatus(
              showVolume: false,
              showPlaySpeed: false,
              showBrightness: false,
              controller: widget.controller,
              statusSize: widget.buffingSize,
            ),
          ],
        ),
      ),
    );
  }

  // 顶部自定义装饰器
  final topDecoration = const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color.fromRGBO(0, 0, 0, 0.65),
        Color.fromRGBO(0, 0, 0, 0),
      ],
    ),
  );

  // 底部自定义装饰器
  final bottomDecoration = const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [
        Color.fromRGBO(0, 0, 0, 0.75),
        Color.fromRGBO(0, 0, 0, 0),
      ],
    ),
  );

  // 构建控制层
  Widget _buildVisibleControls() {
    final controller = widget.controller;
    return ValueListenableBuilder3<bool, bool, bool>(
      first: controller.controlVisible,
      second: controller.screenLocked,
      third: controller.miniWindow,
      builder: (_, visible, locked, isMiniWindow, __) {
        return AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: const Duration(milliseconds: 80),
          child: Stack(
            children: [
              if (isMiniWindow)
                CustomPlayerControlsMini(
                  controller: controller,
                )
              else ...[
                CustomPlayerControlsTop(
                  title: widget.title,
                  controller: controller,
                  leading: widget.leading,
                  subTitle: widget.subTitle,
                  decoration: topDecoration,
                  actions: widget.topActions,
                ),
                CustomPlayerControlsBottom(
                  controller: controller,
                  decoration: bottomDecoration,
                  actions: widget.bottomActions,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

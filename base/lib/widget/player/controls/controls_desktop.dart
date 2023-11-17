import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
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
  // 是否展示音量按钮
  final bool showVolume;

  // 是否展示倍速按钮
  final bool showSpeed;

  // 是否展示迷你屏幕按钮
  final bool showMiniScreen;

  // 是否展示全屏按钮
  final bool showFullScreen;

  // 是否展示进度条两侧的文本
  final bool showProgressText;

  // 是否展示时间
  final bool showTimer;

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
    this.showSpeed = true,
    this.showVolume = true,
    this.showMiniScreen = true,
    this.showFullScreen = true,
    this.showProgressText = true,
    this.showTimer = true,
  });

  @override
  State<StatefulWidget> createState() => _DesktopCustomPlayerControlsState();
}

/*
* 自定义播放器控制层-桌面端
* @author wuxubaiyang
* @Time 2023/11/6 16:54
*/
class _DesktopCustomPlayerControlsState
    extends State<DesktopCustomPlayerControls> {
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
    return Focus(
      onKey: (_, __) => KeyEventResult.handled,
      child: Listener(
        // 滚轮操作音量
        onPointerSignal: (signal) {
          if (signal is PointerScrollEvent) {
            if (signal.scrollDelta.dy > 0) {
              controller.volumeLower();
            } else {
              controller.volumeRaise();
            }
          }
        },
        child: RawKeyboardListener(
          autofocus: true,
          onKey: _keyEvent,
          focusNode: FocusNode(),
          child: GestureDetector(
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
          ),
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
        return AnimatedCrossFade(
          firstCurve: Curves.easeIn,
          secondCurve: Curves.easeOut,
          firstChild: const SizedBox(),
          duration: const Duration(milliseconds: 120),
          crossFadeState: CrossFadeState.values[visible ? 1 : 0],
          secondChild: Stack(
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
                  showTimer: widget.showTimer,
                  decoration: topDecoration,
                  actions: widget.topActions,
                ),
                CustomPlayerControlsBottom(
                  controller: controller,
                  showSpeed: widget.showSpeed,
                  decoration: bottomDecoration,
                  showVolume: widget.showVolume,
                  actions: widget.bottomActions,
                  showMiniScreen: widget.showMiniScreen,
                  showFullScreen: widget.showFullScreen,
                  showProgressText: widget.showProgressText,
                ),
              ],
            ],
          ),
          layoutBuilder: (topChild, _, bottomChild, __) {
            return Stack(children: [bottomChild, topChild]);
          },
        );
      },
    );
  }

  // 键盘与事件对照表
  Map<LogicalKeyboardKey, void Function()> get keyEventMap => {
        // 方向键上音量增加
        LogicalKeyboardKey.arrowUp: widget.controller.volumeRaise,
        // 方向键下音量减少
        LogicalKeyboardKey.arrowDown: widget.controller.volumeLower,
        // 方向键左控制快退
        LogicalKeyboardKey.arrowLeft: widget.controller.seekBackward,
        // 方向键右控制快进
        LogicalKeyboardKey.arrowRight: widget.controller.seekForward,
        // 空格键暂停/恢复播放
        LogicalKeyboardKey.space: widget.controller.resumeOrPause,
        // esc取消全屏
        LogicalKeyboardKey.escape: () => widget.controller.setFullscreen(false),
      };

  // 处理键盘事件
  void _keyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      final key = event.logicalKey;
      if (keyEventMap.containsKey(key)) {
        widget.controller.setControlVisible(true);
        keyEventMap[key]?.call();
      }
    }
  }
}

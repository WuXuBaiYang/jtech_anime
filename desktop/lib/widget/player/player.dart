import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jtech_anime_base/base.dart';
import 'package:window_manager/window_manager.dart';
import 'bottom.dart';
import 'status.dart';
import 'top.dart';

/*
* 自定义视频播放器
* @author wuxubaiyang
* @Time 2023/8/19 14:30
*/
class CustomDesktopVideoPlayer extends StatefulWidget {
  // 控制器
  final CustomVideoPlayerController controller;

  // 标题
  final Widget? title;

  // 顶部leading
  final Widget? leading;

  // 副标题
  final Widget? subTitle;

  // 顶部按钮集合
  final List<Widget> topActions;

  // 底部按钮集合
  final List<Widget> bottomActions;

  const CustomDesktopVideoPlayer({
    super.key,
    required this.controller,
    this.title,
    this.leading,
    this.subTitle,
    this.topActions = const [],
    this.bottomActions = const [],
  });

  @override
  State<StatefulWidget> createState() => _CustomDesktopVideoPlayerState();
}

/*
* 自定义视频播放器-状态
* @author wuxubaiyang
* @Time 2023/8/19 14:30
*/
class _CustomDesktopVideoPlayerState extends State<CustomDesktopVideoPlayer> {
  // 播放进度控制
  final playerSeekStream = StreamController<Duration?>.broadcast();

  @override
  void initState() {
    super.initState();
    // 控制器
    final controller = widget.controller;
    // 监听全屏状态切换
    widget.controller.controlFullscreen.addListener(() {
      final value = controller.controlFullscreen.value;
      windowManager.setFullScreen(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.dark(
          primary: kPrimaryColor,
          secondary: kSecondaryColor,
          onPrimary: Colors.white,
        ),
        iconButtonTheme: const IconButtonThemeData(
          style: ButtonStyle(
            iconSize: MaterialStatePropertyAll(20),
            iconColor: MaterialStatePropertyAll(Colors.white),
          ),
        ),
        sliderTheme: const SliderThemeData(
          trackHeight: 2,
          thumbShape: RoundSliderThumbShape(
            enabledThumbRadius: 6,
          ),
          overlayShape: RoundSliderOverlayShape(
            overlayRadius: 14,
          ),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
          size: 20,
        ),
      ),
      child: Focus(
        // 处理所有键盘事件，防止焦点抢夺
        onKey: (_, __) => KeyEventResult.handled,
        child: Listener(
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
            child: CustomVideoPlayer(
              controller: widget.controller,
              controls: (state) {
                return _buildControls(context, state);
              },
            ),
          ),
        ),
      ),
    );
  }

  // 构建控制器
  Widget _buildControls(BuildContext context, state) {
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
            _buildScreenBrightness(),
            ValueListenableBuilder<bool>(
              valueListenable: controller.controlVisible,
              builder: (_, visible, __) {
                return AnimatedOpacity(
                  opacity: visible ? 1 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: Stack(
                    children: [
                      _buildTopActions(),
                      _buildBottomActions(),
                    ],
                  ),
                );
              },
            ),
            _buildControlsStatus(),
          ],
        ),
      ),
    );
  }

  // 构建屏幕亮度控制
  Widget _buildScreenBrightness() {
    final controller = widget.controller;
    return ValueListenableBuilder<double>(
      valueListenable: controller.screenBrightness,
      builder: (_, brightness, __) {
        return Opacity(
          opacity: 1 - brightness,
          child: Container(color: Colors.black87),
        );
      },
    );
  }

  // 构建顶栏
  Widget _buildTopActions() {
    return CustomPlayerControlsTop(
      controller: widget.controller,
      title: widget.title,
      leading: widget.leading,
      subTitle: widget.subTitle,
      actions: widget.topActions,
    );
  }

  // 构建底栏
  Widget _buildBottomActions() {
    return CustomPlayerControlsBottom(
      actions: widget.bottomActions,
      controller: widget.controller,
      seekStream: playerSeekStream.stream,
    );
  }

  // 构建控制器状态
  Widget _buildControlsStatus() {
    return CustomPlayerControlsStatus(
      controller: widget.controller,
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
        LogicalKeyboardKey.escape: () {
          widget.controller.setFullscreen(false);
        },
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

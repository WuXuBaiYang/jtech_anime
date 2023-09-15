import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jtech_anime_base/base.dart';
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
  Widget build(BuildContext context) {
    return CustomVideoPlayer(
      controller: widget.controller,
      controls: (state) {
        return _buildControls(context, state);
      },
    );
  }

  // 构建控制器
  Widget _buildControls(BuildContext context, state) {
    final controller = widget.controller;
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: _keyEvent,
      child: MouseRegion(
        onHover: (_) => controller.setControlVisible(true),
        onEnter: (_) => controller.setControlVisible(true),
        onExit: (_) => controller.setControlVisible(false),
        child: Stack(
          children: [
            ValueListenableBuilder<bool>(
              valueListenable: controller.controlVisible,
              builder: (_, visible, __) {
                return GestureDetector(
                  onTap: () =>
                      widget.controller.resumeOrPause().then((playing) {
                    if (playing) controller.setControlVisible(true);
                  }),
                  child: AnimatedOpacity(
                    opacity: visible ? 1 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: Stack(
                      children: [
                        _buildTopActions(),
                        _buildBottomActions(),
                      ],
                    ),
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

  // 处理键盘事件
  void _keyEvent(KeyEvent event) {
    final controller = widget.controller;
    // 监听方向键，上下控制音量，左右控制进度,空格键暂停/恢复播放
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowUp: // 增加音量
        VolumeTool.raise();
        break;
      case LogicalKeyboardKey.arrowDown: // 降低音量
        VolumeTool.lower();
        break;
      case LogicalKeyboardKey.arrowLeft: // 快退
        controller
            .seekTo(controller.state.position - const Duration(seconds: 3));
        break;
      case LogicalKeyboardKey.arrowRight: // 快进
        controller
            .seekTo(controller.state.position + const Duration(seconds: 3));
        break;
      case LogicalKeyboardKey.space: // 暂停/恢复播放
        controller.resumeOrPause();
        break;
    }
  }
}

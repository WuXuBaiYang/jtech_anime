import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jtech_anime_base/common/notifier.dart';
import 'package:jtech_anime_base/widget/listenable_builders.dart';
import 'package:jtech_anime_base/widget/player/widgets/brightness.dart';
import 'package:jtech_anime_base/widget/player/widgets/progress.dart';
import 'bottom.dart';
import 'controls.dart';
import 'side.dart';
import 'status.dart';
import 'top.dart';

/*
* 自定义播放器控制层-移动端
* @author wuxubaiyang
* @Time 2023/11/7 9:50
*/
class MobileCustomPlayerControls extends CustomPlayerControls {
  // 是否展示音量按钮
  final bool showVolume;

  // 是否展示倍速按钮
  final bool showSpeed;

  // 是否展示进度条两侧的文本
  final bool showProgressText;

  // 是否展示时间
  final bool showTimer;

  const MobileCustomPlayerControls({
    super.key,
    required super.controller,
    super.theme,
    super.title,
    super.leading,
    super.subTitle,
    super.buffingSize,
    super.topActions,
    super.bottomActions,
    this.showVolume = true,
    this.showSpeed = true,
    this.showProgressText = true,
    this.showTimer = true,
  });

  @override
  State<StatefulWidget> createState() => _MobileCustomPlayerControlsState();
}

/*
* 自定义播放器控制层-移动端
* @author wuxubaiyang
* @Time 2023/11/6 16:54
*/
class _MobileCustomPlayerControlsState
    extends State<MobileCustomPlayerControls> {
  // 倍速播放状态展示控制
  final visiblePlaySpeed = ValueChangeNotifier<bool>(false);

  // 播放进度控制
  final playerSeekStream = StreamController<Duration?>.broadcast();

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: widget.getTheme(context),
      child: _buildControls(context),
    );
  }

  // 构建控制器
  Widget _buildControls(BuildContext context) {
    Duration? tempPosition;
    final controller = widget.controller;
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width, screenHeight = screenSize.height;
    return GestureDetector(
      // 单击
      onTap: controller.toggleControlVisible,
      // 双击
      onDoubleTap: () {
        if (controller.isScreenLocked) return;
        widget.controller.resumeOrPause().then((playing) {
          if (playing) controller.setControlVisible(false);
        });
      },
      // 长点击
      onLongPressStart: (_) {
        if (!controller.state.playing || controller.isScreenLocked) return;
        visiblePlaySpeed.setValue(true);
        HapticFeedback.vibrate();
      },
      onLongPressEnd: (_) => visiblePlaySpeed.setValue(false),
      // 垂直滑动
      onVerticalDragStart: (_) {
        if (controller.isScreenLocked) return;
        controller.setControlVisible(false);
      },
      onVerticalDragUpdate: (details) {
        if (controller.isScreenLocked) return;
        // 区分左右屏
        final offset = details.delta.dy / screenHeight;
        if (details.globalPosition.dx > screenWidth / 2) {
          controller.setVolume(controller.currentVolume - offset);
        } else {
          controller.setBrightness(controller.currentBrightness - offset);
        }
      },
      onHorizontalDragStart: (_) {
        if (controller.isScreenLocked) return;
        controller.setControlVisible(true, ongoing: true);
      },
      onHorizontalDragUpdate: (details) {
        if (controller.isScreenLocked) return;
        final current = tempPosition?.inMilliseconds ??
            controller.state.position.inMilliseconds;
        final total = controller.state.duration.inMilliseconds;
        final value =
            current + (details.delta.dx / screenHeight * total * 0.35).toInt();
        if (value < 0 || value > total) return;
        tempPosition = Duration(milliseconds: value);
        playerSeekStream.add(tempPosition);
      },
      onHorizontalDragEnd: (_) {
        controller.setControlVisible(true);
        playerSeekStream.add(null);
        tempPosition = null;
      },
      child: Stack(
        children: [
          CustomPlayerBrightness(controller: widget.controller),
          _buildVisibleControls(),
          _buildControlsStatus(),
        ],
      ),
    );
  }

  // 构建控制层
  Widget _buildVisibleControls() {
    final controller = widget.controller;
    return ValueListenableBuilder2<bool, bool>(
      first: controller.controlVisible,
      second: controller.screenLocked,
      builder: (_, visible, locked, __) {
        return AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: const Duration(milliseconds: 80),
          child: Container(
            color: Colors.black38,
            child: Stack(
              children: [
                if (!locked) ...[
                  CustomPlayerControlsTop(
                    controller: controller,
                    title: widget.title,
                    leading: widget.leading,
                    subTitle: widget.subTitle,
                    actions: widget.topActions,
                    showTimer: widget.showTimer,
                  ),
                  CustomPlayerControlsBottom(
                    showMiniScreen: false,
                    showFullScreen: false,
                    controller: controller,
                    showSpeed: widget.showSpeed,
                    showVolume: widget.showVolume,
                    actions: widget.bottomActions,
                    seekStream: playerSeekStream.stream,
                    showProgressText: widget.showProgressText,
                  ),
                ],
                CustomPlayerControlsSide(
                  controller: controller,
                ),
                if (locked)
                  CustomPlayerProgress(
                    controller: controller,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 构建状态曾
  Widget _buildControlsStatus() {
    return ValueListenableBuilder(
      valueListenable: visiblePlaySpeed,
      builder: (_, visible, __) {
        return CustomPlayerControlsStatus(
          visiblePlaySpeed: visible,
          controller: widget.controller,
          statusSize: widget.buffingSize,
        );
      },
    );
  }
}

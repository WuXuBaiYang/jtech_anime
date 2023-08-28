import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:jtech_anime/common/notifier.dart';
import 'package:jtech_anime/tool/tool.dart';
import 'package:jtech_anime/widget/listenable_builders.dart';
import 'package:jtech_anime/widget/player/controller.dart';
import 'package:jtech_anime/widget/player/controls/bottom.dart';
import 'package:jtech_anime/widget/player/controls/side.dart';
import 'package:jtech_anime/widget/player/controls/status.dart';
import 'package:jtech_anime/widget/player/controls/top.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:screen_brightness/screen_brightness.dart';

/*
* 自定义视频播放器
* @author wuxubaiyang
* @Time 2023/8/19 14:30
*/
class CustomVideoPlayer extends StatefulWidget {
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

  const CustomVideoPlayer({
    super.key,
    required this.controller,
    this.title,
    this.leading,
    this.subTitle,
    this.topActions = const [],
    this.bottomActions = const [],
  });

  @override
  State<StatefulWidget> createState() => _CustomVideoPlayerState();
}

/*
* 自定义视频播放器-状态
* @author wuxubaiyang
* @Time 2023/8/19 14:30
*/
class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  // 音量变化流
  final volumeValue = ValueChangeNotifier<double>(0);

  // 倍速播放控制
  final controlPlaySpeed = ValueChangeNotifier<bool>(false);

  // 播放进度控制
  final playerSeekStream = StreamController<Duration?>.broadcast();

  @override
  Widget build(BuildContext context) {
    return Video(
      pauseUponEnteringBackgroundMode: true,
      resumeUponEnteringForegroundMode: true,
      controller: widget.controller.controller,
      controls: (state) => _buildControls(context, state),
    );
  }

  // 构建控制器
  Widget _buildControls(BuildContext context, VideoState state) {
    final controller = widget.controller;
    final brightness = ScreenBrightness();
    final screenWidth = Tool.getScreenWidth(context);
    final screenHeight = Tool.getScreenHeight(context);
    Duration? tempPosition;
    return Stack(
      children: [
        ValueListenableBuilder2(
          second: controller.screenLocked,
          first: controller.controlVisible,
          builder: (_, visible, locked, __) {
            return GestureDetector(
              onDoubleTap: () {
                if (locked) return;
                widget.controller.resumeOrPause().then((playing) {
                  if (playing) controller.setControlVisible(false);
                });
              },
              onVerticalDragStart: (_) {
                if (locked) return;
                controller.setControlVisible(false);
              },
              onVerticalDragUpdate: (details) async {
                if (locked) return;
                // 区分左右屏
                final dragPercentage = details.delta.dy / screenHeight;
                if (details.globalPosition.dx > screenWidth / 2) {
                  final current = volumeValue.value;
                  final value = current - dragPercentage;
                  if (value < 0 || value > 1) return;
                  FlutterVolumeController.setVolume(value);
                  volumeValue.setValue(value);
                } else {
                  final current = await brightness.current;
                  final value = current - dragPercentage;
                  if (value < 0 || value > 1) return;
                  brightness.setScreenBrightness(value);
                }
              },
              onHorizontalDragStart: (_) {
                if (locked) return;
                controller.setControlVisible(true, ongoing: true);
              },
              onHorizontalDragUpdate: (details) {
                if (locked) return;
                final current = tempPosition?.inMilliseconds ??
                    controller.state.position.inMilliseconds;
                final total = controller.state.duration.inMilliseconds;
                final value = current +
                    (details.delta.dx / screenHeight * total * 0.35).toInt();
                if (value < 0 || value > total) return;
                tempPosition = Duration(milliseconds: value);
                playerSeekStream.add(tempPosition);
              },
              onHorizontalDragEnd: (_) {
                playerSeekStream.add(null);
                tempPosition = null;
              },
              onTap: () => controller.setControlVisible(!visible),
              onLongPressEnd: (_) => controlPlaySpeed.setValue(false),
              onLongPressStart: (_) {
                if (!controller.state.playing || locked) return;
                controlPlaySpeed.setValue(true);
              },
              child: AnimatedOpacity(
                opacity: visible ? 1 : 0,
                duration: const Duration(milliseconds: 150),
                child: Container(
                  color: Colors.black38,
                  child: Stack(
                    children: [
                      if (!locked) ...[
                        _buildTopActions(),
                        _buildBottomActions(),
                      ],
                      _buildSideActions(locked),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        _buildControlsStatus(),
      ],
    );
  }

  // 构建侧栏
  Widget _buildSideActions(bool locked) {
    return CustomPlayerControlsSide(
      controller: widget.controller,
      locked: locked,
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
      volumeValue: volumeValue,
      controller: widget.controller,
      controlPlaySpeed: controlPlaySpeed,
    );
  }
}

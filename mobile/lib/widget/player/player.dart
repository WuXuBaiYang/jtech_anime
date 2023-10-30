import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jtech_anime_base/base.dart';
import 'bottom.dart';
import 'progress.dart';
import 'side.dart';
import 'status.dart';
import 'top.dart';

/*
* 自定义视频播放器
* @author wuxubaiyang
* @Time 2023/8/19 14:30
*/
class CustomMobileVideoPlayer extends StatefulWidget {
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

  const CustomMobileVideoPlayer({
    super.key,
    required this.controller,
    this.title,
    this.leading,
    this.subTitle,
    this.topActions = const [],
    this.bottomActions = const [],
  });

  @override
  State<StatefulWidget> createState() => _CustomMobileVideoPlayerState();
}

/*
* 自定义视频播放器-状态
* @author wuxubaiyang
* @Time 2023/8/19 14:30
*/
class _CustomMobileVideoPlayerState extends State<CustomMobileVideoPlayer> {
  // 倍速显隐控制
  final controlPlaySpeed = ValueChangeNotifier<bool>(false);

  // 音量显隐控制
  final controlVolume = ValueChangeNotifier<bool>(false);

  // 亮度显隐控制
  final controlBrightness = ValueChangeNotifier<bool>(false);

  // 播放进度控制
  final playerSeekStream = StreamController<Duration?>.broadcast();

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _getPlayerTheme(context),
      child: CustomVideoPlayer(
        controller: widget.controller,
        controls: (state) {
          return _buildControls(context, state);
        },
      ),
    );
  }

  // 播放器样式
  ThemeData _getPlayerTheme(BuildContext context) {
    return Theme.of(context).copyWith(
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
    );
  }

  // 构建控制器
  Widget _buildControls(BuildContext context, state) {
    return Stack(
      children: [
        _buildScreenBrightness(),
        _buildVisibleControls(),
        _buildControlsStatus(),
      ],
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
          child: Container(color: Colors.black.withOpacity(0.75)),
        );
      },
    );
  }

  // 构建显示控制层
  Widget _buildVisibleControls() {
    final controller = widget.controller;
    final screenWidth = Tool.getScreenWidth(context);
    final screenHeight = Tool.getScreenHeight(context);
    Duration? tempPosition;
    return ValueListenableBuilder2(
      second: controller.screenLocked,
      first: controller.controlVisible,
      builder: (_, visible, locked, __) {
        return GestureDetector(
          onTap: () {
            controller.setControlVisible(!visible);
          },
          onDoubleTap: () {
            if (locked) return;
            widget.controller.resumeOrPause().then((playing) {
              if (playing) controller.setControlVisible(false);
            });
          },
          onLongPressEnd: (_) {
            controlPlaySpeed.setValue(false);
          },
          onLongPressStart: (_) {
            if (!controller.state.playing || locked) return;
            controlPlaySpeed.setValue(true);
            HapticFeedback.vibrate();
          },
          onVerticalDragEnd: (_) {
            controlBrightness.setValue(false);
            controlVolume.setValue(false);
          },
          onVerticalDragStart: (_) {
            if (locked) return;
            controller.setControlVisible(false);
          },
          onHorizontalDragEnd: (_) {
            playerSeekStream.add(null);
            tempPosition = null;
          },
          onVerticalDragUpdate: (details) {
            if (locked) return;
            // 区分左右屏
            final offset = details.delta.dy / screenHeight;
            if (details.globalPosition.dx > screenWidth / 2) {
              controller.setVolume(controller.currentVolume - offset);
              controlVolume.setValue(true);
            } else {
              controller.setBrightness(controller.currentBrightness - offset);
              controlBrightness.setValue(true);
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
          child: AnimatedOpacity(
            opacity: visible ? 1 : 0,
            duration: const Duration(milliseconds: 80),
            child: Container(
              color: Colors.black38,
              child: Stack(
                children: [
                  if (!locked) ...[
                    _buildTopActions(),
                    _buildBottomActions(),
                  ],
                  _buildSideActions(locked),
                  if (locked) _buildLockProgress(),
                ],
              ),
            ),
          ),
        );
      },
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
      controlVolume: controlVolume,
      controller: widget.controller,
      controlPlaySpeed: controlPlaySpeed,
      controlBrightness: controlBrightness,
    );
  }

  // 构建锁屏状态下的进度条
  Widget _buildLockProgress() {
    return CustomPlayerLockProgress(
      controller: widget.controller,
    );
  }
}

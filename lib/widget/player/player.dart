import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jtech_anime/common/notifier.dart';
import 'package:jtech_anime/manage/theme.dart';
import 'package:jtech_anime/tool/date.dart';
import 'package:jtech_anime/tool/debounce.dart';
import 'package:jtech_anime/tool/tool.dart';
import 'package:jtech_anime/widget/listenable_builders.dart';
import 'package:jtech_anime/widget/player/controller.dart';
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
  final List<Widget>? topActions;

  // 底部按钮集合
  final List<Widget>? bottomActions;

  const CustomVideoPlayer({
    super.key,
    required this.controller,
    this.title,
    this.leading,
    this.subTitle,
    this.topActions,
    this.bottomActions,
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
  // 音量调整
  final controlVolume = ValueChangeNotifier<bool>(false);

  // 亮度调整
  final controlBrightness = ValueChangeNotifier<bool>(false);

  // 静音状态
  final controlMute = ValueChangeNotifier<bool>(false);

  // 长按快进状态
  final controlPlaySpeed = ValueChangeNotifier<bool>(false);

  // 音量变化流
  final volumeStream = StreamController<double>.broadcast();

  @override
  void initState() {
    super.initState();
    // 长按快进状态监听
    double speed = 1.0;
    controlPlaySpeed.addListener(() {
      if (controlPlaySpeed.value) {
        speed = widget.controller.state.rate;
        widget.controller.setRate(3.0);
      } else {
        widget.controller.setRate(speed);
        speed = 1.0;
      }
    });
    // 监听音量变化
    FlutterVolumeController.addListener((v) {
      volumeStream.sink.add(v);
      controlVolume.setValue(true);
      Debounce.c(
        delay: const Duration(milliseconds: 200),
        () => controlVolume.setValue(false),
        'updateVolume',
      );
    });
    // 监听亮度变化
    ScreenBrightness().onCurrentBrightnessChanged.listen((_) {
      controlBrightness.setValue(true);
      Debounce.c(
        delay: const Duration(milliseconds: 200),
        () => controlBrightness.setValue(false),
        'updateBrightness',
      );
    });
    // 监听静音状态变化
    controlMute.addListener(() {
      FlutterVolumeController.setMute(controlMute.value);
    });
  }

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
    return Stack(
      children: [
        ValueListenableBuilder2(
          second: controller.screenLocked,
          first: controller.controlVisible,
          builder: (_, visible, locked, __) {
            return GestureDetector(
              onDoubleTap: () async {
                if (locked) return;
                final playing = await widget.controller.resumeOrPause();
                if (playing) controller.setControlVisible(false);
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
                  if (dragPercentage > 0) {
                    FlutterVolumeController.lowerVolume(dragPercentage * 5);
                  } else {
                    FlutterVolumeController.raiseVolume(
                        dragPercentage.abs() * 5);
                  }
                } else {
                  final current = await brightness.current;
                  brightness.setScreenBrightness(current - dragPercentage);
                }
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
                      _buildBuffingStatus(),
                      _buildLockButton(locked),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        _buildVolume(),
        _buildPlaySpeed(),
        _buildBrightness(),
      ],
    );
  }

  // 构建锁定按钮
  Widget _buildLockButton(bool locked) {
    final controller = widget.controller;
    final iconData = locked ? FontAwesomeIcons.lock : FontAwesomeIcons.lockOpen;
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: IconButton(
          icon: Icon(iconData),
          color: locked ? kPrimaryColor : null,
          onPressed: () {
            controller.setControlVisible(true);
            controller.setScreenLocked(!locked);
          },
        ),
      ),
    );
  }

  // 构建顶栏
  Widget _buildTopActions() {
    return Align(
      alignment: Alignment.topCenter,
      child: ListTile(
        title: widget.title,
        leading: widget.leading,
        subtitle: widget.subTitle,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...widget.topActions ?? [],
          ],
        ),
      ),
    );
  }

  // 构建底栏
  Widget _buildBottomActions() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildBottomActionsProgress(),
            Row(
              children: [
                _buildBottomActionsPlay(),
                const Spacer(),
                ...widget.bottomActions ?? [],
                const SizedBox(width: 14),
                _buildBottomActionsRate(),
                const SizedBox(width: 14),
                _buildBottomActionsMute(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 构建底部状态播放按钮
  Widget _buildBottomActionsPlay() {
    final controller = widget.controller;
    return StreamBuilder<bool>(
      stream: controller.stream.playing,
      builder: (_, snap) {
        final playing = controller.state.playing;
        return IconButton(
          onPressed: () {
            controller.setControlVisible(true);
            controller.resumeOrPause();
          },
          icon: Icon(playing ? FontAwesomeIcons.pause : FontAwesomeIcons.play),
        );
      },
    );
  }

  // 构建底部
  Widget _buildBottomActionsProgress() {
    Duration? tempProgress;
    final controller = widget.controller;
    const textStyle = TextStyle(color: Colors.white54, fontSize: 12);
    return StatefulBuilder(
      builder: (_, state) {
        return StreamBuilder<Duration>(
          stream: controller.stream.position,
          builder: (_, snap) {
            final buffer = controller.state.buffer;
            final total = controller.state.duration;
            final progress = tempProgress ?? controller.state.position;
            return Row(
              children: [
                Text(progress.format(DurationPattern.fullTime),
                    style: textStyle),
                Expanded(
                  child: Slider(
                    inactiveColor: Colors.black26,
                    max: total.inMilliseconds.toDouble(),
                    value: progress.inMilliseconds.toDouble(),
                    secondaryActiveColor: kPrimaryColor.withOpacity(0.3),
                    secondaryTrackValue: buffer.inMilliseconds.toDouble(),
                    onChangeStart: (_) =>
                        controller.setControlVisible(true, ongoing: true),
                    onChanged: (v) => state(
                        () => tempProgress = Duration(milliseconds: v.toInt())),
                    onChangeEnd: (v) {
                      controller.seekTo(Duration(milliseconds: v.toInt()));
                      controller.setControlVisible(true);
                      tempProgress = null;
                    },
                  ),
                ),
                Text(total.format(DurationPattern.fullTime), style: textStyle),
              ],
            );
          },
        );
      },
    );
  }

  // 构建底部倍速按钮
  Widget _buildBottomActionsRate() {
    final controller = widget.controller;
    return StreamBuilder(
      stream: controller.stream.rate,
      builder: (_, snap) {
        return DropdownButton<double>(
          elevation: 0,
          value: snap.data ?? 1.0,
          underline: const SizedBox(),
          dropdownColor: Colors.black87,
          onTap: () => controller.setControlVisible(true, ongoing: true),
          items: [0.5, 1.0, 2.0, 3.0, 4.0]
              .map((e) => DropdownMenuItem<double>(
                    value: e,
                    child: Text('x$e'),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null) controller.setRate(v);
            controller.setControlVisible(true);
          },
        );
      },
    );
  }

  // 构建底部静音按钮
  Widget _buildBottomActionsMute() {
    final controller = widget.controller;
    return ValueListenableBuilder<bool>(
      valueListenable: controlMute,
      builder: (_, isMute, __) {
        return IconButton(
          onPressed: () {
            controlMute.setValue(!controlMute.value);
            controller.setControlVisible(true);
          },
          icon: Icon(isMute
              ? FontAwesomeIcons.volumeXmark
              : FontAwesomeIcons.volumeLow),
        );
      },
    );
  }

  // 构建长按播放倍速提示
  Widget _buildPlaySpeed() {
    return Align(
      alignment: Alignment.center,
      child: ValueListenableBuilder<bool>(
        valueListenable: controlPlaySpeed,
        builder: (_, showPlaySpeed, __) {
          return AnimatedOpacity(
            opacity: showPlaySpeed ? 1.0 : 0,
            duration: const Duration(milliseconds: 150),
            child: const Card(
              elevation: 0,
              color: Colors.black38,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('快进中', style: TextStyle(fontSize: 14)),
                    SizedBox(width: 4),
                    Icon(FontAwesomeIcons.anglesRight, size: 18),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 控制音量变化
  Widget _buildVolume() {
    return Align(
      alignment: Alignment.centerLeft,
      child: ValueListenableBuilder<bool>(
        valueListenable: controlVolume,
        builder: (_, showVolume, __) {
          return _buildVerticalProgress(
            showVolume,
            volumeStream.stream,
            icon: const Icon(FontAwesomeIcons.volumeLow),
          );
        },
      ),
    );
  }

  // 控制亮度变化
  Widget _buildBrightness() {
    return Align(
      alignment: Alignment.centerRight,
      child: ValueListenableBuilder<bool>(
        valueListenable: controlBrightness,
        builder: (_, showBrightness, __) {
          return _buildVerticalProgress(
            showBrightness,
            ScreenBrightness().onCurrentBrightnessChanged,
            icon: const Icon(FontAwesomeIcons.sun),
          );
        },
      ),
    );
  }

  // 构建垂直进度条
  Widget _buildVerticalProgress(
    bool visible,
    Stream<double> progress, {
    Widget? icon,
  }) {
    return AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: const Duration(milliseconds: 150),
      child: Transform.rotate(
        angle: 270 * pi / 180,
        child: Card(
          elevation: 0,
          color: Colors.black38,
          clipBehavior: Clip.hardEdge,
          margin: const EdgeInsets.all(24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: StreamBuilder<double>(
            stream: progress,
            builder: (_, snap) {
              final value = snap.data ?? 0;
              return Stack(
                alignment: Alignment.centerLeft,
                children: [
                  SizedBox.fromSize(
                    size: const Size(160, 40),
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.transparent,
                      value: value,
                    ),
                  ),
                  Padding(padding: const EdgeInsets.all(8), child: icon),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // 构建缓冲状态提示
  Widget _buildBuffingStatus() {
    final controller = widget.controller;
    return Align(
      alignment: Alignment.center,
      child: StreamBuilder<bool>(
        stream: controller.stream.buffering,
        builder: (_, snap) {
          if (!(snap.data ?? false)) return const SizedBox();
          return const SizedBox.square(
            dimension: 35,
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

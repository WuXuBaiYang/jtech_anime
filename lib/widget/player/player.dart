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
  // 锁定状态
  final controlLocked = ValueChangeNotifier<bool>(false);

  // 是否展示控制
  final controlVisible = ValueChangeNotifier<bool>(true);

  // 音量调整
  final controlVolume = ValueChangeNotifier<bool>(false);

  // 亮度调整
  final controlBrightness = ValueChangeNotifier<bool>(false);

  // 静音状态
  final controlMute = ValueChangeNotifier<bool>(false);

  // 音量变化流
  final volumeStream = StreamController<double>.broadcast();

  // 定时器
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // 监听控制器变化控制层得显示隐藏
    controlVisible.addListener(() {
      if (!controlVisible.value) {
        _timer?.cancel();
        _timer = null;
      } else {
        _timer ??= Timer.periodic(
          const Duration(milliseconds: 1500),
          (_) => controlVisible.setValue(false),
        );
      }
    });
    // 监听音量变化
    FlutterVolumeController.addListener((v) {
      volumeStream.sink.add(v);
      controlVolume.setValue(true);
      Debounce.c(
        () => controlVolume.setValue(false),
        'updateVolume',
      );
    });
    // 监听亮度变化
    ScreenBrightness().onCurrentBrightnessChanged.listen((_) {
      controlBrightness.setValue(true);
      Debounce.c(
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
    final brightness = ScreenBrightness();
    final screenWidth = Tool.getScreenWidth(context);
    final screenHeight = Tool.getScreenHeight(context);
    return Stack(
      children: [
        ValueListenableBuilder2(
          first: controlVisible,
          second: controlLocked,
          builder: (_, visible, locked, __) {
            return GestureDetector(
              onTap: () => controlVisible.setValue(!visible),
              onVerticalDragStart: (_) => controlVisible.setValue(false),
              onDoubleTap: () async {
                final playing = await widget.controller.resumeOrPause();
                if (playing) controlVisible.setValue(false);
              },
              onVerticalDragUpdate: (details) async {
                // 如果当前锁屏则不执行操作
                if (locked) return;
                // 区分左右屏
                final dragPercentage = details.delta.dy / screenHeight;
                if (details.globalPosition.dx > screenWidth / 2) {
                  final current =
                      await FlutterVolumeController.getVolume() ?? 0;
                  FlutterVolumeController.setVolume(current - dragPercentage);
                } else {
                  final current = await brightness.current;
                  brightness.setScreenBrightness(current - dragPercentage);
                }
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
          onPressed: controller.toggleScreenLock,
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
        final playing = snap.data ?? false;
        return IconButton(
          onPressed: snap.hasData ? controller.resumeOrPause : null,
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
                    onChanged: (v) => state(
                        () => tempProgress = Duration(milliseconds: v.toInt())),
                    onChangeEnd: (v) {
                      controller.seekTo(Duration(milliseconds: v.toInt()));
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
          items: [0.5, 1.0, 2.0, 3.0, 4.0]
              .map((e) => DropdownMenuItem<double>(
                    value: e,
                    child: Text('x$e'),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null) controller.setRate(v);
          },
        );
      },
    );
  }

  // 构建底部静音按钮
  Widget _buildBottomActionsMute() {
    return ValueListenableBuilder<bool>(
      valueListenable: controlMute,
      builder: (_, isMute, __) {
        return IconButton(
          onPressed: () => controlMute.setValue(!controlMute.value),
          icon: Icon(isMute
              ? FontAwesomeIcons.volumeXmark
              : FontAwesomeIcons.volumeLow),
        );
      },
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

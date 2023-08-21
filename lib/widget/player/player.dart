import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jtech_anime/common/notifier.dart';
import 'package:jtech_anime/manage/theme.dart';
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
  final controlVisible = ValueChangeNotifier<bool>(false);

  // 音量调整
  final controlVolume = ValueChangeNotifier<bool>(false);

  // 亮度调整
  final controlBrightness = ValueChangeNotifier<bool>(false);

  // 静音状态
  final controlMute = ValueChangeNotifier<bool>(false);

  // 定时器
  Timer? _timer;

  // 记录静音前得音量
  double? _lastVolume;

  @override
  void initState() {
    super.initState();
    final controller = widget.controller;
    // 监听播放状态，当暂停中则强制显示控制层
    controller.stream.playing.listen((e) {
      if (e) return;
      controlVisible.setValue(true);
      _timer?.cancel();
      _timer = null;
    });
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
    controller.stream.volume.listen((_) {
      controlVisible.setValue(false);
      controlVolume.setValue(true);
      Debounce.c(
        () => controlVolume.setValue(false),
        'updateVolume',
      );
    });
    // 监听亮度变化
    ScreenBrightness().onCurrentBrightnessChanged.listen((_) {
      controlBrightness.setValue(true);
      controlVisible.setValue(false);
      Debounce.c(
        () => controlBrightness.setValue(false),
        'updateBrightness',
      );
    });
    // 监听静音状态变化
    controlMute.addListener(() {
      if (controlMute.value) {
        widget.controller.setVolume(_lastVolume ?? 0);
      } else {
        _lastVolume = widget.controller.state.volume;
      }
      controlMute.setValue(!controlMute.value);
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
    final screenWidth = Tool.getScreenWidth(context);
    final screenHeight = Tool.getScreenHeight(context);
    return ValueListenableBuilder2(
      first: controlVisible,
      second: controlLocked,
      builder: (_, visible, locked, __) {
        return GestureDetector(
          onDoubleTap: () async {
            final playing = await widget.controller.resumeOrPause();
            if (playing) controlVisible.setValue(false);
          },
          onTap: () {
            // 暂停等状态则不通过点击显隐控制层
            if (!controller.state.playing ||
                controlVolume.value ||
                controlBrightness.value) return;
            controlVisible.setValue(!visible);
          },
          onVerticalDragUpdate: (details) {
            // 如果当前锁屏则不执行操作
            if (locked) return;
            // 区分左右屏
            final dragPercentage = details.delta.dy / screenHeight;
            if (details.globalPosition.dx > screenWidth / 2) {
              controller.setVolume(dragPercentage * 100);
            } else {
              ScreenBrightness().setScreenBrightness(dragPercentage);
            }
          },
          child: AnimatedOpacity(
            opacity: visible ? 1 : 0,
            duration: const Duration(milliseconds: 150),
            child: Container(
              color: Colors.black38,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (!locked) ...[
                    _buildVolume(),
                    _buildBrightness(),
                    _buildTopActions(),
                    _buildBottomActions(),
                  ],
                  _buildLockButton(locked),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 构建锁定按钮
  Widget _buildLockButton(bool locked) {
    final controller = widget.controller;
    final iconData = locked ? FontAwesomeIcons.lock : FontAwesomeIcons.lockOpen;
    return Align(
      alignment: Alignment.centerRight,
      child: IconButton(
        icon: Icon(iconData),
        color: locked ? kPrimaryColor : null,
        onPressed: controller.toggleScreenLock,
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
          children: [
            ...widget.topActions ?? [],
          ],
        ),
      ),
    );
  }

  // 构建底栏
  Widget _buildBottomActions() {
    final controller = widget.controller;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const MaterialSeekBar(),
          Row(
            children: [
              StreamBuilder<bool>(
                stream: controller.stream.playing,
                builder: (_, snap) {
                  final playing = snap.data ?? false;
                  return IconButton(
                      onPressed: snap.hasData ? controller.resumeOrPause : null,
                      icon: Icon(playing
                          ? FontAwesomeIcons.pause
                          : FontAwesomeIcons.play));
                },
              ),
              const Spacer(),
              ...widget.bottomActions ?? [],
              _buildBottomActionsRate(),
              _buildBottomActionsMute(),
            ],
          ),
        ],
      ),
    );
  }

  // 构建底部倍速按钮
  Widget _buildBottomActionsRate() {
    final controller = widget.controller;
    return StreamBuilder(
      stream: controller.stream.rate,
      builder: (_, snap) {
        return DropdownButton<double>(
          value: snap.data ?? 1.0,
          items: [0.5, 1.0, 2.0, 3.0, 4.0]
              .map((e) => DropdownMenuItem<double>(
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

  // 音量变化图标集合
  final volumeIcons = const [
    FontAwesomeIcons.volumeXmark,
    FontAwesomeIcons.volumeOff,
    FontAwesomeIcons.volumeLow,
    FontAwesomeIcons.volumeHigh,
  ];

  // 控制音量变化
  Widget _buildVolume() {
    final controller = widget.controller;
    final length = volumeIcons.length;
    final pcie = 100 / length;
    return Align(
      alignment: Alignment.centerLeft,
      child: ValueListenableBuilder<bool>(
        valueListenable: controlVolume,
        builder: (_, showVolume, __) {
          return _buildVerticalProgress(
            showVolume,
            controller.stream.volume,
            icon: StreamBuilder(
              stream: controller.stream.volume,
              builder: (_, snap) {
                final value = snap.data ?? 0;
                int index = value ~/ pcie;
                if (index >= length) index = length - 1;
                return Icon(volumeIcons[index]);
              },
            ),
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
          color: Colors.black54,
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
}

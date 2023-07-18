import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jtech_anime/common/notifier.dart';
import 'package:jtech_anime/tool/date.dart';
import 'package:jtech_anime/widget/future_builder.dart';
import 'package:jtech_anime/widget/listenable_builders.dart';
import 'package:jtech_anime/widget/player/controller.dart';

/*
* 自定义视频播放器，控制层
* @author wuxubaiyang
* @Time 2023/7/17 11:00
*/
class CustomVideoPlayerControlLayer extends StatefulWidget {
  // 控制器
  final CustomVideoPlayerController controller;

  // 锁定回调
  final VoidCallback? onLock;

  // 播放/暂停回调
  final VoidCallback? onPlay;

  // 播放下一集回调
  final VoidCallback? onNext;

  // 视频比例调整回调
  final VoidCallback? onRatio;

  // 视频跳动进度
  final VoidCallback? onSeek;

  // 弹出层背景色
  final Color overlayColor;

  // 主色调
  final Color? primaryColor;

  // 标题
  final Widget? title;

  // 动作按钮集合
  final List<Widget> actions;

  const CustomVideoPlayerControlLayer({
    super.key,
    required this.overlayColor,
    required this.controller,
    this.actions = const [],
    this.primaryColor,
    this.onRatio,
    this.onLock,
    this.onPlay,
    this.onNext,
    this.onSeek,
    this.title,
  });

  @override
  State<CustomVideoPlayerControlLayer> createState() =>
      _CustomVideoPlayerControlLayerState();
}

class _CustomVideoPlayerControlLayerState
    extends State<CustomVideoPlayerControlLayer> {
  // 记录当前时间
  final currentDateTime = ValueChangeNotifier<DateTime>(DateTime.now());

  // 拖拽时进度
  final seekProgress = ValueChangeNotifier<Duration?>(null);

  // 计时器
  late Timer timer = Timer.periodic(const Duration(seconds: 1), (t) {
    currentDateTime.setValue(DateTime.now());
  });

  // 电量
  final battery = Battery();

  // 连接状态
  final connectivity = Connectivity();

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: const TextStyle(color: Colors.white),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: _buildTopBar(),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildBottomBar(),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: _buildSideBar(),
          ),
        ],
      ),
    );
  }

  // 内间距
  final padding = const EdgeInsets.symmetric(vertical: 8);

  // 边框
  BoxDecoration _getBarDecoration(bool isTop) {
    final colors = [Colors.black, Colors.black.withOpacity(0.01)];
    return BoxDecoration(
      gradient: LinearGradient(
        stops: const [0, 1],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isTop ? colors : colors.reversed.toList(),
      ),
    );
  }

  // 构建顶部条
  Widget _buildTopBar() {
    return Container(
      padding: padding,
      width: double.maxFinite,
      decoration: _getBarDecoration(true),
      child: Row(
        children: [
          const BackButton(),
          DefaultTextStyle(
            style: const TextStyle(fontSize: 18),
            child: widget.title ?? const SizedBox(),
          ),
          const Spacer(),
          _buildTopBarTime(),
          const SizedBox(width: 8),
          _buildTopBarBattery(),
          const SizedBox(width: 14),
          _buildTopBarSource(),
          const SizedBox(width: 14),
        ],
      ),
    );
  }

  // 构建资源状态(网络[wifi、手机]，本地)
  Widget _buildTopBarSource() {
    // 如果是本地资源则直接返回
    if (widget.controller.isLocalFile) {
      return const Text('[已下载]');
    }
    // 如果是网络资源则需要检查状态
    if (widget.controller.isNetwork) {
      return CacheFutureBuilder<ConnectivityResult>(
        future: connectivity.checkConnectivity,
        builder: (_, snap) {
          if (snap.hasData) {
            final iconData = {
              ConnectivityResult.mobile: FontAwesomeIcons.signal,
              ConnectivityResult.wifi: FontAwesomeIcons.wifi,
              ConnectivityResult.ethernet: FontAwesomeIcons.ethernet,
            }[snap.data!];
            if (iconData != null) return Icon(iconData, size: 14);
          }
          return const SizedBox();
        },
      );
    }
    return const SizedBox();
  }

  // 构建时间
  Widget _buildTopBarTime() {
    return ValueListenableBuilder<DateTime>(
      valueListenable: currentDateTime,
      builder: (_, dateTime, __) {
        return Text(dateTime.format(DatePattern.time));
      },
    );
  }

  // 电量对应图标
  final batteryIcons = [
    FontAwesomeIcons.batteryEmpty,
    FontAwesomeIcons.batteryQuarter,
    FontAwesomeIcons.batteryHalf,
    FontAwesomeIcons.batteryThreeQuarters,
    FontAwesomeIcons.batteryFull,
  ];

  // 构建电量
  Widget _buildTopBarBattery() {
    return CacheFutureBuilder<int>(
        future: () => battery.batteryLevel,
        builder: (_, snap) {
          if (snap.hasData) {
            final index = snap.data! ~/ (100 / batteryIcons.length);
            return Icon(batteryIcons[index.clamp(0, 4)]);
          }
          return const SizedBox();
        });
  }

  // 构建底部条
  Widget _buildBottomBar() {
    return Container(
      padding: padding,
      width: double.maxFinite,
      decoration: _getBarDecoration(false),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildBottomSeekbar(),
          Row(
            children: [
              const SizedBox(width: 14),
              _buildBottomBarPlay(),
              _buildBottomBarNext(),
              const Spacer(),
              ...widget.actions,
              const SizedBox(width: 8),
              _buildBottomBarRatio(),
              const SizedBox(width: 14),
            ],
          ),
        ],
      ),
    );
  }

  // 构建进度条
  Widget _buildBottomSeekbar() {
    final controller = widget.controller;
    const pattern = DurationPattern.fullTime;
    return ValueListenableBuilder2<Duration, Duration?>(
      first: controller.progress,
      second: seekProgress,
      builder: (_, progress, seekProgress, __) {
        seekProgress ??= progress;
        final total = controller.total.inMilliseconds.toDouble();
        final value = seekProgress.inMilliseconds.toDouble();
        final initialized = controller.isInitialized;
        return Row(
          children: [
            const SizedBox(width: 14),
            Text(seekProgress.format(pattern)),
            Expanded(
              child: Slider(
                max: initialized ? total : 0,
                value: initialized ? value : 0,
                onChanged: (v) {
                  final value = Duration(milliseconds: v.toInt());
                  this.seekProgress.setValue(value);
                  widget.onSeek?.call();
                },
                onChangeEnd: (v) async {
                  final value = Duration(milliseconds: v.toInt());
                  await controller.setProgress(value);
                  this.seekProgress.setValue(null);
                },
              ),
            ),
            Text(controller.total.format(pattern)),
            const SizedBox(width: 14),
          ],
        );
      },
    );
  }

  // 构建播放/暂停按钮
  Widget _buildBottomBarPlay() {
    final controller = widget.controller;
    return ValueListenableBuilder(
      valueListenable: widget.controller,
      builder: (_, state, __) {
        final canPressed = [
          PlayerState.playing,
          PlayerState.paused,
          PlayerState.ready2Play,
        ].contains(state);
        return IconButton(
          icon: Icon(controller.isPause
              ? FontAwesomeIcons.play
              : FontAwesomeIcons.pause),
          onPressed: canPressed
              ? () {
                  widget.onPlay?.call();
                  controller.isPlaying
                      ? controller.pause()
                      : controller.resume();
                }
              : null,
        );
      },
    );
  }

  // 构建下一条视频按钮
  Widget _buildBottomBarNext() {
    final controller = widget.controller;
    return ValueListenableBuilder(
      valueListenable: controller.nextVideo,
      builder: (_, video, __) {
        final hasNext = video != null;
        return IconButton(
          icon: const Icon(FontAwesomeIcons.forwardStep),
          onPressed: hasNext
              ? () {
                  widget.onNext?.call();
                  controller.playNextVideo();
                }
              : null,
        );
      },
    );
  }

  // 视频比例图标集合
  final ratioIcons = {
    PlayerRatio.normal: Icons.aspect_ratio,
    PlayerRatio.fill: Icons.fullscreen,
  };

  // 构建视频比例切换
  Widget _buildBottomBarRatio() {
    final controller = widget.controller;
    return ValueListenableBuilder<PlayerRatio>(
      valueListenable: controller.ratio,
      builder: (_, ratio, __) {
        return IconButton(
          icon: Icon(ratioIcons[ratio]),
          onPressed: controller.isInitialized
              ? () {
                  widget.onRatio?.call();
                  var index = ratio.index + 1;
                  if (index >= PlayerRatio.values.length) index = 0;
                  final value = PlayerRatio.values[index];
                  controller.setVideoRatio(value);
                }
              : null,
        );
      },
    );
  }

  // 构建侧边条
  Widget _buildSideBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ValueListenableBuilder(
            valueListenable: widget.controller,
            builder: (_, state, __) {
              if (widget.controller.isPause) return const SizedBox();
              return IconButton(
                onPressed: () {
                  widget.controller.setLocked(true);
                  widget.onLock?.call();
                },
                icon: const Icon(FontAwesomeIcons.lockOpen),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // 销毁计时器
    timer.cancel();
    super.dispose();
  }
}

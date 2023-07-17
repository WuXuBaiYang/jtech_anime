import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jtech_anime/common/notifier.dart';
import 'package:jtech_anime/tool/date.dart';
import 'package:jtech_anime/widget/future_builder.dart';
import 'package:jtech_anime/widget/player/controller.dart';
import 'layer.dart';

/*
* 自定义视频播放器，控制层
* @author wuxubaiyang
* @Time 2023/7/17 11:00
*/
class CustomVideoPlayerControlLayer extends StatefulWidget {
  // 控制器
  final CustomVideoPlayerController controller;

  // 锁定回调
  final VoidCallback? onLocked;

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
    this.onLocked,
    this.title,
  });

  @override
  State<CustomVideoPlayerControlLayer> createState() =>
      _CustomVideoPlayerControlLayerState();
}

class _CustomVideoPlayerControlLayerState
    extends State<CustomVideoPlayerControlLayer> with CustomVideoPlayerLayer {
  // 记录当前时间
  final currentDateTime = ValueChangeNotifier<DateTime>(DateTime.now());

  // 计时器
  late Timer timer = Timer.periodic(const Duration(seconds: 1), (t) {
    currentDateTime.setValue(DateTime.now());
  });

  // 电量
  final battery = Battery();

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
          DefaultTextStyle(
            style: TextStyle(color: widget.primaryColor),
            child: _buildTopBarSource(),
          ),
          const SizedBox(width: 14),
          _buildTopBarTime(),
          const SizedBox(width: 8),
          _buildTopBarBattery(),
          const SizedBox(width: 14),
        ],
      ),
    );
  }

  // 构建资源状态(网络[wifi、手机卡]，本地)
  Widget _buildTopBarSource() {
    if (widget.controller.isLocalFile) {
      return const Text('[已下载]');
    }
    if (widget.controller.isNetwork) {
      return const Text('[在线]');
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
      child: Row(
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
              ? FontAwesomeIcons.pause
              : FontAwesomeIcons.play),
          onPressed: canPressed
              ? () => controller.isPlaying
                  ? controller.pause()
                  : controller.resume()
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
          onPressed: hasNext ? () => controller.playNextVideo() : null,
        );
      },
    );
  }

  // 视频比例图标集合
  final ratioIcons = {
    PlayerRatio.normal: FontAwesomeIcons.leftRight,
    PlayerRatio.fill: FontAwesomeIcons.maximize,
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
          IconButton(
            onPressed: () {
              widget.controller.setLocked(true);
              widget.onLocked?.call();
            },
            icon: const Icon(FontAwesomeIcons.lockOpen),
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

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mobile/tool/brightness.dart';
import 'package:jtech_anime_base/base.dart';

/*
* 自定义播放器控制层-状态层
* @author wuxubaiyang
* @Time 2023/8/28 10:19
*/
class CustomPlayerControlsStatus extends StatefulWidget {
  // 播放器控制器
  final CustomVideoPlayerController controller;

  // 倍速播放控制
  final ValueChangeNotifier<bool> controlPlaySpeed;

  // 音量显隐控制
  final ValueChangeNotifier<bool>? controlVolume;

  // 亮度显隐控制
  final ValueChangeNotifier<bool>? controlBrightness;

  const CustomPlayerControlsStatus({
    super.key,
    required this.controller,
    required this.controlPlaySpeed,
    this.controlVolume,
    this.controlBrightness,
  });

  @override
  State<StatefulWidget> createState() => _CustomPlayerControlsStatusState();
}

/*
* 自定义播放器控制层-状态层-状态
* @author wuxubaiyang
* @Time 2023/8/28 10:19
*/
class _CustomPlayerControlsStatusState
    extends State<CustomPlayerControlsStatus> {
  @override
  void initState() {
    super.initState();
    // 长按快进状态监听
    final controller = widget.controller;
    double speed = controller.state.rate;
    widget.controlPlaySpeed.addListener(() {
      if (widget.controlPlaySpeed.value) {
        speed = widget.controller.state.rate;
        widget.controller.setRate(speed + 1.0);
      } else {
        widget.controller.setRate(speed);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          _buildVolume(),
          _buildPlaySpeed(),
          _buildBrightness(),
          _buildBuffingStatus(),
        ],
      ),
    );
  }

  // 构建长按播放倍速提示
  Widget _buildPlaySpeed() {
    return Align(
      alignment: Alignment.center,
      child: ValueListenableBuilder<bool>(
        valueListenable: widget.controlPlaySpeed,
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
    if (widget.controlVolume == null) return const SizedBox();
    return Align(
      alignment: Alignment.centerLeft,
      child: ValueListenableBuilder<bool>(
        valueListenable: widget.controlVolume!,
        builder: (_, showVolume, __) {
          return StreamBuilder<double>(
              stream: widget.controller.stream.volume,
              builder: (_, snap) {
                final value = (snap.data ?? 100) / 100;
                return _buildVerticalProgress(showVolume, value,
                    icon: const Icon(FontAwesomeIcons.volumeLow));
              });
        },
      ),
    );
  }

  // 控制亮度变化
  Widget _buildBrightness() {
    if (widget.controlBrightness == null) return const SizedBox();
    return Align(
      alignment: Alignment.centerRight,
      child: ValueListenableBuilder<bool>(
        valueListenable: widget.controlBrightness!,
        builder: (_, showBrightness, __) {
          return StreamBuilder<double>(
            stream: BrightnessTool.stream,
            builder: (_, snap) {
              final value = snap.data ?? 0;
              return _buildVerticalProgress(showBrightness, value,
                  icon: const Icon(FontAwesomeIcons.sun));
            },
          );
        },
      ),
    );
  }

  // 构建垂直进度条
  Widget _buildVerticalProgress(bool visible, double progress, {Widget? icon}) {
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
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              SizedBox.fromSize(
                size: const Size(160, 40),
                child: LinearProgressIndicator(
                  backgroundColor: Colors.transparent,
                  value: progress,
                ),
              ),
              Padding(padding: const EdgeInsets.all(8), child: icon),
            ],
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
          return const StatusBox(
            status: StatusBoxStatus.loading,
            statusSize: 30,
          );
        },
      ),
    );
  }
}

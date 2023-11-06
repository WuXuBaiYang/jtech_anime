import 'package:flutter/material.dart';
import 'package:jtech_anime_base/base.dart';
import 'package:jtech_anime_base/widget/player/widgets/brightness_status.dart';
import 'package:jtech_anime_base/widget/player/widgets/buffing_status.dart';
import 'package:jtech_anime_base/widget/player/widgets/play_speed_status.dart';
import 'package:jtech_anime_base/widget/player/widgets/volume_status.dart';

/*
* 自定义播放器控制层-状态层
* @author wuxubaiyang
* @Time 2023/8/28 10:19
*/
class CustomPlayerControlsStatus extends StatefulWidget {
  // 播放器控制器
  final CustomVideoPlayerController controller;

  // 缓冲状态大小
  final double? statusSize;

  // 是否展示快进状态
  final bool visiblePlaySpeed;

  // 是否展示音量状态
  final bool showVolume;

  // 是否展示亮度状态
  final bool showBrightness;

  // 是否展示缓冲状态
  final bool showBuffing;

  // 是否展示倍速状态
  final bool showPlaySpeed;

  const CustomPlayerControlsStatus({
    super.key,
    required this.controller,
    this.statusSize,
    this.showVolume = true,
    this.showBuffing = true,
    this.showPlaySpeed = true,
    this.showBrightness = true,
    this.visiblePlaySpeed = false,
  });

  @override
  State<CustomPlayerControlsStatus> createState() =>
      _CustomPlayerControlsStatusState();
}

class _CustomPlayerControlsStatusState
    extends State<CustomPlayerControlsStatus> {
  // 控制音量状态展示
  final visibleVolume = ValueChangeNotifier<bool>(false);

  // 控制亮度状态展示
  final visibleBrightness = ValueChangeNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    // 监听音量变化
    widget.controller.volume.addListener(() {
      visibleVolume.setValue(true);
      Debounce.c(
        () => visibleVolume.setValue(false),
        'visibleVolume',
        delay: const Duration(milliseconds: 400),
      );
    });
    // 监听亮度变化
    widget.controller.screenBrightness.addListener(() {
      visibleBrightness.setValue(true);
      Debounce.c(
        () => visibleBrightness.setValue(false),
        'visibleBrightness',
        delay: const Duration(milliseconds: 400),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          if (widget.showVolume) _buildVolume(),
          if (widget.showPlaySpeed) _buildPlaySpeed(),
          if (widget.showBrightness) _buildBrightness(),
          if (widget.showBuffing) _buildBuffingStatus(),
        ],
      ),
    );
  }

  // 构建长按播放倍速提示
  Widget _buildPlaySpeed() {
    return Align(
      alignment: Alignment.center,
      child: CustomPlayerPlaySpeedStatus(
        controller: widget.controller,
        visible: widget.visiblePlaySpeed,
      ),
    );
  }

  // 控制音量变化
  Widget _buildVolume() {
    return Align(
      alignment: Alignment.centerLeft,
      child: ValueListenableBuilder<bool>(
        valueListenable: visibleVolume,
        builder: (_, visible, __) {
          return CustomPlayerVolumeStatus(
            controller: widget.controller,
            visible: visible,
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
        valueListenable: visibleBrightness,
        builder: (_, visible, __) {
          return CustomPlayerBrightnessStatus(
            controller: widget.controller,
            visible: visible,
          );
        },
      ),
    );
  }

  // 构建缓冲状态提示
  Widget _buildBuffingStatus() {
    return Align(
      alignment: Alignment.center,
      child: CustomPlayerBufferingStatus(
        controller: widget.controller,
      ),
    );
  }
}

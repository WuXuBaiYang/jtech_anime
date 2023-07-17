import 'package:flutter/material.dart';
import 'package:jtech_anime/widget/player/controller.dart';

/*
* 自定义视频播放器，手势交互层
* @author wuxubaiyang
* @Time 2023/7/17 11:00
*/
class CustomVideoPlayerGestureLayer extends StatefulWidget {
  // 控制器
  final CustomVideoPlayerController controller;

  // 点击事件
  final VoidCallback? onTap;

  // 播放速度
  final double speed;

  // 初始化播放速度
  final double initialSpeed;

  const CustomVideoPlayerGestureLayer({
    super.key,
    required this.controller,
    this.initialSpeed = 1,
    this.speed = 3,
    this.onTap,
  });

  @override
  State<CustomVideoPlayerGestureLayer> createState() =>
      _CustomVideoPlayerGestureLayerState();
}

/*
* 自定义视频播放器，手势交互层-状态
* @author wuxubaiyang
* @Time 2023/7/17 12:42
*/
class _CustomVideoPlayerGestureLayerState
    extends State<CustomVideoPlayerGestureLayer> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: widget.onTap,
      // 双击播放/暂停
      onDoubleTap: _controlVideo,
      // 长按倍速，停止恢复倍速
      onLongPressEnd: (_) => _setPlaySpeed(false),
      onLongPressStart: (_) => _setPlaySpeed(true),
      // 屏幕垂直滑动事件
      onVerticalDragEnd: (_) => _lastSeekDy = null,
      onVerticalDragUpdate: (d) => _seekControl(d, size.width / 2, size.height),
    );
  }

  // 双击播放或暂停事件
  void _controlVideo() {
    if (widget.controller.isPlaying) {
      widget.controller.pause();
    } else if (widget.controller.isPause) {
      widget.controller.resume();
    }
  }

  // 设置播放速度
  void _setPlaySpeed(bool start) => widget.controller
      .setPlaybackSpeed(start ? widget.speed : widget.initialSpeed);

  // 记录上次滑动位置
  double? _lastSeekDy;

  // 滑动控制音量/亮度
  void _seekControl(DragUpdateDetails details, double halfWide, double height) {
    final p = details.globalPosition;
    if (_lastSeekDy == null) {
      _lastSeekDy = p.dy;
      return;
    }
    // 计算滑动方向（确定增加），计算增减比例(2倍)
    final direction = _lastSeekDy! - p.dy;
    final ratio = direction.abs() / height * 2;
    if (p.dx < halfWide) {
      // 左侧屏幕滑垂直滑动调整亮度
      var v = widget.controller.brightness.value;
      v = direction > 0 ? v + ratio : v - ratio;
      widget.controller.setBrightness(v);
    } else {
      // 右侧屏幕垂直滑动调整音量
      var v = widget.controller.volume.value;
      v = direction > 0 ? v + ratio : v - ratio;
      widget.controller.setVolume(v);
    }
    _lastSeekDy = p.dy;
  }
}

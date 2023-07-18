import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jtech_anime/widget/player/controller.dart';

// 手势状态切换
typedef PlayerGestureCallback = void Function(bool start, double value);

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

  // 音量控制
  final PlayerGestureCallback? onVolume;

  // 亮度控制
  final PlayerGestureCallback? onBrightness;

  // 倍数控制
  final PlayerGestureCallback? onSpeed;

  const CustomVideoPlayerGestureLayer({
    super.key,
    required this.controller,
    this.onTap,
    this.onSpeed,
    this.onVolume,
    this.speed = 3,
    this.onBrightness,
    this.initialSpeed = 1,
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
      onVerticalDragEnd: (_) => _endSeekControl(),
      onVerticalDragUpdate: (d) =>
          _startSeekControl(d, size.width / 2, size.height),
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
  void _setPlaySpeed(bool start) {
    if (!widget.controller.isPlaying) return;
    if (start) HapticFeedback.vibrate();
    final value = start ? widget.speed : widget.initialSpeed;
    widget.controller.setPlaybackSpeed(value);
    widget.onSpeed?.call(start, value);
  }

  // 记录上次滑动位置
  double? _lastSeekDy;

  // 滑动控制音量/亮度
  void _startSeekControl(
      DragUpdateDetails details, double halfWide, double height) {
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
      widget.onBrightness?.call(true, v);
    } else {
      // 右侧屏幕垂直滑动调整音量
      var v = widget.controller.volume.value;
      v = direction > 0 ? v + ratio : v - ratio;
      widget.controller.setVolume(v);
      widget.onVolume?.call(true, v);
    }
    _lastSeekDy = p.dy;
  }

  // 结束滑动控制
  void _endSeekControl() {
    _lastSeekDy = null;
    widget.onVolume?.call(false, widget.controller.volume.value);
    widget.onBrightness?.call(false, widget.controller.brightness.value);
  }
}

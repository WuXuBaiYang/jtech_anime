import 'package:flutter/material.dart';
import 'package:jtech_anime/widget/player/controller.dart';
import 'layer.dart';

/*
* 自定义视频播放器，控制层
* @author wuxubaiyang
* @Time 2023/7/17 11:00
*/
class CustomVideoPlayerControlLayer extends StatelessWidget
    with CustomVideoPlayerLayer {
  // 控制器
  final CustomVideoPlayerController controller;

  // 触发锁屏事件
  final VoidCallback? onLocked;

  // 弹出层背景色
  final Color overlayColor;

  CustomVideoPlayerControlLayer({
    super.key,
    required this.overlayColor,
    required this.controller,
    this.onLocked,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox();
  }
}

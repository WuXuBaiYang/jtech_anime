import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jtech_anime/widget/player/controller.dart';
import 'package:jtech_anime/widget/status_box.dart';

import 'layer.dart';

/*
* 自定义视频播放器，状态层
* @author wuxubaiyang
* @Time 2023/7/17 15:52
*/
class CustomVideoPlayerStateLayer extends StatelessWidget
    with CustomVideoPlayerLayer {
  // 控制器
  final CustomVideoPlayerController controller;

  // 占位组件
  final Widget? placeholder;

  CustomVideoPlayerStateLayer({
    super.key,
    required this.controller,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    // 如果是播放中则不显示状态
    if (controller.isPlaying) return const SizedBox();
    // 如果无状态则显示占位图
    if (controller.value == PlayerState.none) {
      return placeholder ?? const SizedBox();
    }
    // 如果是暂停/准备播放则展示播放按钮
    if (controller.isPause || controller.isReady2Play) {
      return const Icon(FontAwesomeIcons.play, size: 45);
    }
    // 展示其他状态
    final text = {
      PlayerState.loading: '正在加载视频~',
      PlayerState.buffering: '正在缓冲视频~',
    }[controller.value];
    return StatusBox(
      status: StatusBoxStatus.loading,
      title: Text(text ?? ''),
      color: Colors.white54,
      animSize: 35,
      space: 14,
    );
  }
}

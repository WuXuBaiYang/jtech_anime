import 'package:flutter/material.dart';
import 'package:jtech_anime_base/widget/player/controller.dart';

/*
* 自定义播放器控制层-播放进度
* @author wuxubaiyang
* @Time 2023/11/6 14:36
*/
class CustomPlayerProgress extends StatelessWidget {
  // 播放器控制器
  final CustomVideoPlayerController controller;

  const CustomPlayerProgress({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: controller.stream.position,
      builder: (_, snap) {
        final total = controller.state.duration;
        final progress = controller.state.position;
        final ratio = progress.inMilliseconds / total.inMilliseconds;
        return LinearProgressIndicator(
          minHeight: 2,
          value: ratio.isNaN ? 0 : ratio,
          backgroundColor: Colors.transparent,
        );
      },
    );
  }
}

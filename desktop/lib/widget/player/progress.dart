import 'package:flutter/material.dart';
import 'package:jtech_anime_base/base.dart';

/*
* 自定义播放器控制层-mini窗口状态下的进度条
* @author wuxubaiyang
* @Time 2023/8/28 10:19
*/
class CustomPlayerMiniProgress extends StatefulWidget {
  // 播放器控制器
  final CustomVideoPlayerController controller;

  const CustomPlayerMiniProgress({
    super.key,
    required this.controller,
  });

  @override
  State<StatefulWidget> createState() => _CustomPlayerMiniProgressState();
}

/*
* 自定义播放器控制层-mini窗口-状态
* @author wuxubaiyang
* @Time 2023/8/28 10:19
*/
class _CustomPlayerMiniProgressState extends State<CustomPlayerMiniProgress> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: _buildMiniProgress(),
    );
  }

  // 构建mini窗口下的进度条
  Widget _buildMiniProgress() {
    final controller = widget.controller;
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

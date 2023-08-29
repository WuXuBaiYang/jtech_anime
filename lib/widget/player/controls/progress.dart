import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jtech_anime/manage/theme.dart';
import 'package:jtech_anime/widget/player/controller.dart';

/*
* 自定义播放器控制层-锁屏状态下的进度条
* @author wuxubaiyang
* @Time 2023/8/28 10:19
*/
class CustomPlayerLockProgress extends StatefulWidget {
  // 播放器控制器
  final CustomVideoPlayerController controller;

  const CustomPlayerLockProgress({
    super.key,
    required this.controller,
  });

  @override
  State<StatefulWidget> createState() => _CustomPlayerLockProgressState();
}

/*
* 自定义播放器控制层-侧边-状态
* @author wuxubaiyang
* @Time 2023/8/28 10:19
*/
class _CustomPlayerLockProgressState extends State<CustomPlayerLockProgress> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: _buildLockProgress(),
    );
  }

  // 构建锁屏状态下的进度条
  Widget _buildLockProgress() {
    final controller = widget.controller;
    return StreamBuilder<Duration>(
      stream: controller.stream.position,
      builder: (_, snap) {
        final total = controller.state.duration;
        final progress = controller.state.position;
        final ratio = progress.inMilliseconds / total.inMilliseconds;
        return LinearProgressIndicator(
            value: ratio, minHeight: 2, backgroundColor: Colors.transparent);
      },
    );
  }
}

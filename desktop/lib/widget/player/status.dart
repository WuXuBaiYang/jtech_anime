import 'dart:math';
import 'package:flutter/material.dart';
import 'package:jtech_anime_base/base.dart';

/*
* 自定义播放器控制层-状态层
* @author wuxubaiyang
* @Time 2023/8/28 10:19
*/
class CustomPlayerControlsStatus extends StatefulWidget {
  // 播放器控制器
  final CustomVideoPlayerController controller;

  const CustomPlayerControlsStatus({
    super.key,
    required this.controller,
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
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          _buildBuffingStatus(),
        ],
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
            animSize: 30,
            status: StatusBoxStatus.loading,
          );
        },
      ),
    );
  }
}

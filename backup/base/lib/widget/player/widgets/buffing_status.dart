import 'package:flutter/material.dart';
import 'package:jtech_anime_base/widget/player/controller.dart';
import 'package:jtech_anime_base/widget/status_box.dart';

/*
* 自定义播放器-缓冲状态提示
* @author wuxubaiyang
* @Time 2023/11/6 14:26
*/
class CustomPlayerBufferingStatus extends StatelessWidget {
  // 播放器控制器
  final CustomVideoPlayerController controller;

  // 缓冲状态大小
  final double? statusSize;

  const CustomPlayerBufferingStatus({
    super.key,
    required this.controller,
    this.statusSize,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: controller.stream.buffering,
      builder: (_, snap) {
        if (!(snap.data ?? false)) return const SizedBox();
        return StatusBox(
          status: StatusBoxStatus.loading,
          statusSize: statusSize ?? 65,
        );
      },
    );
  }
}

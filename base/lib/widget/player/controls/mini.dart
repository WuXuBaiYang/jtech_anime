import 'package:flutter/material.dart';
import 'package:jtech_anime_base/base.dart';
import 'package:jtech_anime_base/widget/player/widgets/play_button.dart';
import 'package:jtech_anime_base/widget/player/widgets/progress.dart';

/*
* 自定义播放器控制层-mini窗口状态
* @author wuxubaiyang
* @Time 2023/8/28 10:57
*/
class CustomPlayerControlsMini extends StatelessWidget {
  // 播放器控制器
  final CustomVideoPlayerController controller;

  const CustomPlayerControlsMini({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.75),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: CloseButton(
              onPressed: controller.toggleMiniWindow,
            ),
          ),
          CustomPlayerPlayButton(
            controller: controller,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: CustomPlayerProgress(
              controller: controller,
            ),
          ),
        ],
      ),
    );
  }
}

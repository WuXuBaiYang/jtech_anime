import 'package:flutter/material.dart';
import 'package:jtech_anime_base/widget/player/controller.dart';

/*
* 自定义播放器控制层-亮度
* @author wuxubaiyang
* @Time 2023/11/6 15:15
*/
class CustomPlayerBrightness extends StatelessWidget {
  // 控制器
  final CustomVideoPlayerController controller;

  const CustomPlayerBrightness({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: controller.screenBrightness,
      builder: (_, brightness, __) {
        return Opacity(
          opacity: 1 - brightness,
          child: Container(color: Colors.black.withOpacity(0.75)),
        );
      },
    );
  }
}

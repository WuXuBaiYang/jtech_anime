import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jtech_anime_base/widget/player/controller.dart';
import 'package:jtech_anime_base/widget/vertical_progress.dart';

/*
* 自定义播放器控制层-亮度状态
* @author wuxubaiyang
* @Time 2023/11/6 15:58
*/
class CustomPlayerBrightnessStatus extends StatelessWidget {
  // 播放器控制器
  final CustomVideoPlayerController controller;

  // 是否展示音量控制
  final bool visible;

  // 进度条尺寸
  final Size? size;

  // 外间距
  final EdgeInsetsGeometry? margin;

  const CustomPlayerBrightnessStatus({
    super.key,
    required this.controller,
    this.size,
    this.margin,
    this.visible = false,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: controller.screenBrightness,
      builder: (_, brightness, __) {
        return AnimatedOpacity(
          opacity: visible ? 1.0 : 0,
          duration: const Duration(milliseconds: 150),
          child: VerticalProgressView(
            size: size,
            margin: margin,
            progress: brightness,
            icon: const Icon(FontAwesomeIcons.sun),
          ),
        );
      },
    );
  }
}

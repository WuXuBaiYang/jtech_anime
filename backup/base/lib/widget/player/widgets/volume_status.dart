import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jtech_anime_base/widget/player/controller.dart';
import 'package:jtech_anime_base/widget/vertical_progress.dart';

/*
* 自定义播放器控制层-音量状态
* @author wuxubaiyang
* @Time 2023/11/6 15:58
*/
class CustomPlayerVolumeStatus extends StatelessWidget {
  // 播放器控制器
  final CustomVideoPlayerController controller;

  // 是否展示音量控制
  final bool visible;

  // 进度条尺寸
  final Size? size;

  // 外间距
  final EdgeInsetsGeometry? margin;

  const CustomPlayerVolumeStatus({
    super.key,
    required this.controller,
    this.size,
    this.margin,
    this.visible = false,
  });

  // 获取音量等级图标
  List<IconData> get volumeLevelIcons => [
        FontAwesomeIcons.volumeXmark,
        FontAwesomeIcons.volumeOff,
        FontAwesomeIcons.volumeLow,
        FontAwesomeIcons.volumeHigh,
      ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: controller.volume,
      builder: (_, volume, __) {
        final length = volumeLevelIcons.length - 1;
        final index = (volume * length).ceil();
        final icon = volumeLevelIcons[min(index, length)];
        return AnimatedOpacity(
          opacity: visible ? 1.0 : 0,
          duration: const Duration(milliseconds: 150),
          child: VerticalProgressView(
            size: size,
            margin: margin,
            icon: Icon(icon),
            progress: volume,
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jtech_anime_base/widget/player/controller.dart';

/*
* 自定义播放器控制层-最大化屏幕进入按钮
* @author wuxubaiyang
* @Time 2023/11/6 15:41
*/
class CustomPlayerFullScreenButton extends StatelessWidget {
  // 播放器控制器
  final CustomVideoPlayerController controller;

  const CustomPlayerFullScreenButton({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: controller.controlFullscreen,
      builder: (_, expanded, __) {
        final icon =
            expanded ? FontAwesomeIcons.compress : FontAwesomeIcons.expand;
        return IconButton(
          tooltip: '全屏播放',
          icon: Icon(icon),
          onPressed: () => controller.toggleFullscreen(),
        );
      },
    );
  }
}

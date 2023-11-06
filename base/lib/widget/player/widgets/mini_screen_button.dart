import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jtech_anime_base/widget/player/controller.dart';

/*
* 自定义播放器控制层-mini屏幕进入按钮
* @author wuxubaiyang
* @Time 2023/11/6 15:41
*/
class CustomPlayerMiniScreenButton extends StatelessWidget {
  // 播放器控制器
  final CustomVideoPlayerController controller;

  const CustomPlayerMiniScreenButton({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: controller.miniWindow,
      builder: (_, isMiniWindow, __) {
        return IconButton(
          tooltip: '小窗口播放',
          onPressed: controller.toggleMiniWindow,
          icon: const Icon(FontAwesomeIcons.windowRestore),
        );
      },
    );
  }
}

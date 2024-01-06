import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jtech_anime_base/manage/theme.dart';
import 'package:jtech_anime_base/widget/player/controller.dart';

/*
* 自定义播放器-锁定按钮
* @author wuxubaiyang
* @Time 2023/11/6 16:51
*/
class CustomPlayerLockButton extends StatelessWidget {
  // 播放器控制器
  final CustomVideoPlayerController controller;

  const CustomPlayerLockButton({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller.screenLocked,
      builder: (_, locked, __) {
        final icon = locked ? FontAwesomeIcons.lock : FontAwesomeIcons.lockOpen;
        return IconButton(
          icon: Icon(icon),
          color: locked ? kPrimaryColor : null,
          onPressed: () {
            controller.setControlVisible(true);
            controller.toggleScreenLocked();
          },
        );
      },
    );
  }
}

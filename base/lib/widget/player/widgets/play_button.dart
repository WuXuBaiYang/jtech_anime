import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jtech_anime_base/widget/player/controller.dart';

/*
* 自定义播放器控制层-播放按钮
* @author wuxubaiyang
* @Time 2023/11/6 14:14
*/
class CustomPlayerPlayButton extends StatelessWidget {
  // 播放器控制器
  final CustomVideoPlayerController controller;

  const CustomPlayerPlayButton({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: controller.stream.playing,
      builder: (_, snap) {
        final playing = controller.state.playing;
        final icon = playing ? FontAwesomeIcons.pause : FontAwesomeIcons.play;
        return IconButton(
          icon: Icon(icon),
          onPressed: () {
            controller.setControlVisible(true);
            controller.resumeOrPause();
          },
        );
      },
    );
  }
}

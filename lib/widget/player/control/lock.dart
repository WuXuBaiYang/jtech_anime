import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jtech_anime/common/notifier.dart';
import 'package:jtech_anime/widget/player/controller.dart';

import 'layer.dart';

/*
* 自定义视频播放器，锁定层
* @author wuxubaiyang
* @Time 2023/7/17 16:16
*/
class CustomVideoPlayerLockLayer extends StatelessWidget
    with CustomVideoPlayerLayer {
  // 控制器
  final CustomVideoPlayerController controller;

  // 锁定屏幕展示
  final ValueChangeNotifier<bool> showLock;

  CustomVideoPlayerLockLayer({
    super.key,
    required this.controller,
    required this.showLock,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => show(showLock),
      child: Container(
        color: Colors.transparent,
        child: buildAnimeShow(
          showLock,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(FontAwesomeIcons.lock),
                onPressed: () => controller.setLocked(false),
              ),
              IconButton(
                icon: const Icon(FontAwesomeIcons.lock),
                onPressed: () => controller.setLocked(false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jtech_anime_base/base.dart';
import 'package:jtech_anime_base/widget/player/controller.dart';

/*
* 自定义播放器控制层-音量控制组件
* @author wuxubaiyang
* @Time 2023/11/6 14:03
*/
class CustomPlayerVolume extends StatelessWidget {
  // 播放器控制器
  final CustomVideoPlayerController controller;

  const CustomPlayerVolume({
    super.key,
    required this.controller,
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
    final focusNode = FocusNode();
    return ValueListenableBuilder<double>(
      valueListenable: controller.volume,
      builder: (_, volume, __) {
        final length = volumeLevelIcons.length - 1;
        final index = (volume * length).ceil();
        final icon = volumeLevelIcons[min(index, length)];
        return Stack(
          alignment: Alignment.centerLeft,
          children: [
            IconButton(
              icon: Icon(icon),
              onPressed: controller.toggleMute,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 34),
              child: SizedBox.fromSize(
                size: const Size(120, 10),
                child: Slider(
                  focusNode: focusNode,
                  value: range(volume, 0, 1),
                  onChangeEnd: (_) => focusNode.unfocus(),
                  onChanged: (v) {
                    controller.setVolume(v);
                    controller.setControlVisible(true);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

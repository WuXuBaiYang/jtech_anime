import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jtech_anime_base/widget/player/controller.dart';

/*
* 自定义播放器控制层-播放速度按钮
* @author wuxubaiyang
* @Time 2023/11/6 14:21
*/
class CustomPlayerPlaySpeedButton extends StatelessWidget {
  // 播放器控制器
  final CustomVideoPlayerController controller;

  const CustomPlayerPlaySpeedButton({
    super.key,
    required this.controller,
  });

  // 播放器倍速表
  Map<double, IconData> get playSpeedIcons => {
        0.5: FontAwesomeIcons.gaugeSimple,
        1.0: FontAwesomeIcons.gauge,
        2.0: FontAwesomeIcons.gaugeHigh,
        3.0: FontAwesomeIcons.gaugeHigh,
      };

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<double>(
      stream: controller.stream.rate,
      builder: (_, snap) {
        final rate = snap.data ?? 1.0;
        return PopupMenuButton<double>(
          elevation: 0,
          icon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(playSpeedIcons[rate]),
              const SizedBox(width: 8),
              Text('${rate}x'),
            ],
          ),
          itemBuilder: (_) => playSpeedIcons.entries
              .map<PopupMenuItem<double>>((e) => CheckedPopupMenuItem(
                    value: e.key,
                    checked: rate == e.key,
                    padding: EdgeInsets.zero,
                    child: Text('${e.key}x'),
                  ))
              .toList(),
          onSelected: controller.setRate,
        );
      },
    );
  }
}

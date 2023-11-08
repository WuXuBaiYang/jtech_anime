import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jtech_anime_base/widget/player/controller.dart';

/*
* 自定义播放器控制层-播放速度状态
* @author wuxubaiyang
* @Time 2023/11/6 15:58
*/
class CustomPlayerPlaySpeedStatus extends StatelessWidget {
  // 播放器控制器
  final CustomVideoPlayerController controller;

  // 是否展示音量控制
  final bool visible;

  const CustomPlayerPlaySpeedStatus({
    super.key,
    required this.controller,
    this.visible = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0,
      duration: const Duration(milliseconds: 150),
      child: const Card(
        elevation: 0,
        color: Colors.black38,
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('快进中', style: TextStyle(fontSize: 14)),
              SizedBox(width: 4),
              Icon(FontAwesomeIcons.anglesRight, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

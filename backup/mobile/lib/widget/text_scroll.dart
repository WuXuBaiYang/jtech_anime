import 'package:flutter/material.dart';
import 'package:text_scroll/text_scroll.dart';

/*
* 自定义跑马灯文本组件
* @author wuxubaiyang
* @Time 2023/7/14 15:43
*/
class CustomScrollText extends StatelessWidget {
  // 文本内容
  final String text;

  // 文本样式
  final TextStyle? style;

  // 播放速度
  final ScrollTextSpeed speed;

  const CustomScrollText(this.text,
      {super.key, this.speed = ScrollTextSpeed.normal, this.style});

  const CustomScrollText.slow(this.text, {super.key, this.style})
      : speed = ScrollTextSpeed.slow;

  const CustomScrollText.fast(this.text, {super.key, this.style})
      : speed = ScrollTextSpeed.fast;

  @override
  Widget build(BuildContext context) {
    return TextScroll(
      '$text      ',
      style: style,
      pauseBetween: const Duration(milliseconds: 0),
      velocity: Velocity(pixelsPerSecond: Offset(speed.value, 0)),
    );
  }
}

/*
* 播放速度枚举
* @author wuxubaiyang
* @Time 2023/7/14 15:44
*/
enum ScrollTextSpeed { slow, normal, fast }

/*
* 播放速度枚举扩展
* @author wuxubaiyang
* @Time 2023/7/14 15:45
*/
extension ScrollTextSpeedExtension on ScrollTextSpeed {
  // 获取速度
  double get value => {
        ScrollTextSpeed.slow: 25.0,
        ScrollTextSpeed.normal: 60.0,
        ScrollTextSpeed.fast: 100.0,
      }[this]!;
}

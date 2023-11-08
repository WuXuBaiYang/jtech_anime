import 'package:flutter/material.dart';
import 'package:jtech_anime_base/tool/date.dart';

/*
* 自定义播放器控制层-时间组件
* @author wuxubaiyang
* @Time 2023/11/6 15:31
*/
class TimerView extends StatelessWidget {
  // 时间格式化
  final String? pattern;

  // 文本样式
  final TextStyle? textStyle;

  const TimerView({super.key, this.pattern, this.textStyle});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DateTime>(
      stream: Stream<DateTime>.periodic(
          const Duration(seconds: 1), (_) => DateTime.now()),
      builder: (_, snap) {
        final dateTime = snap.data ?? DateTime.now();
        return Text(
          dateTime.format(pattern ?? DatePattern.time),
          style: textStyle,
        );
      },
    );
  }
}

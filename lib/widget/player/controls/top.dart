import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jtech_anime/tool/date.dart';
import 'package:jtech_anime/widget/future_builder.dart';
import 'package:jtech_anime/widget/player/controller.dart';

/*
* 自定义播放器控制层-顶部
* @author wuxubaiyang
* @Time 2023/8/28 10:19
*/
class CustomPlayerControlsTop extends StatefulWidget {
  // 播放器控制器
  final CustomVideoPlayerController controller;

  // 标题
  final Widget? title;

  // 左边按钮
  final Widget? leading;

  // 副标题
  final Widget? subTitle;

  // 扩展组件
  final List<Widget> actions;

  const CustomPlayerControlsTop({
    super.key,
    required this.controller,
    this.title,
    this.leading,
    this.subTitle,
    this.actions = const [],
  });

  @override
  State<StatefulWidget> createState() => _CustomPlayerControlsTopState();
}

/*
* 自定义播放器控制层-顶部-状态
* @author wuxubaiyang
* @Time 2023/8/28 10:19
*/
class _CustomPlayerControlsTopState extends State<CustomPlayerControlsTop> {
  // 计时器
  final timeClock = Stream<DateTime>.periodic(
      const Duration(seconds: 1), (_) => DateTime.now()).asBroadcastStream();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ListTile(
        title: widget.title,
        subtitle: widget.subTitle,
        leading: widget.leading ?? const BackButton(),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...widget.actions,
            const SizedBox(width: 8),
            _buildTimeAction(),
            const SizedBox(width: 8),
            _buildBatteryAction(),
          ],
        ),
      ),
    );
  }

  // 构建视频播放器头部时间
  Widget _buildTimeAction() {
    return StreamBuilder<DateTime>(
      stream: timeClock,
      builder: (_, snap) {
        final dateTime = snap.data ?? DateTime.now();
        return Text(dateTime.format(DatePattern.time));
      },
    );
  }

  // 电池容量图标集合
  final _batteryIcons = [
    FontAwesomeIcons.batteryEmpty,
    FontAwesomeIcons.batteryQuarter,
    FontAwesomeIcons.batteryHalf,
    FontAwesomeIcons.batteryThreeQuarters,
    FontAwesomeIcons.batteryFull,
  ];

  // 构建电池信息组件
  Widget _buildBatteryAction() {
    return CacheFutureBuilder<int>(
      future: () => Battery().batteryLevel,
      builder: (_, snap) {
        if (snap.hasData) {
          final value = snap.data! - 1;
          final per = 100 / _batteryIcons.length;
          return Icon(_batteryIcons[value ~/ per]);
        }
        return const SizedBox();
      },
    );
  }
}

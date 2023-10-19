import 'package:flutter/material.dart';
import 'package:jtech_anime_base/base.dart';

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
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(0, 0, 0, 0.65),
              Color.fromRGBO(0, 0, 0, 0),
            ],
          ),
        ),
        child: GestureDetector(
          onTap: () {},
          behavior: HitTestBehavior.opaque,
          child: ListTile(
            title: widget.title,
            leading: widget.leading,
            subtitle: widget.subTitle,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...widget.actions,
                const SizedBox(width: 8),
                _buildTimeAction(),
              ],
            ),
          ),
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
}

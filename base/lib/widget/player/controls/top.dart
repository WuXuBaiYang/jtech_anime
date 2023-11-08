import 'package:flutter/material.dart';
import 'package:jtech_anime_base/widget/player/controller.dart';
import 'package:jtech_anime_base/widget/timer.dart';

/*
* 自定义播放器控制层-顶部
* @author wuxubaiyang
* @Time 2023/8/28 10:19
*/
class CustomPlayerControlsTop extends StatelessWidget {
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

  // 是否展示时间
  final bool showTimer;

  // 自定义装饰器
  final Decoration? decoration;

  const CustomPlayerControlsTop({
    super.key,
    required this.controller,
    this.title,
    this.leading,
    this.subTitle,
    this.decoration,
    this.showTimer = true,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: _buildTopActions(),
    );
  }

  // 构建播放器顶部动作条
  Widget _buildTopActions() {
    return Container(
      decoration: decoration,
      child: ListTile(
        title: title,
        subtitle: subTitle,
        leading: leading ?? const BackButton(),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...actions,
            if (actions.isNotEmpty) const SizedBox(width: 8),
            if (showTimer)
              const TimerView(
                // textStyle: TextStyle(
                //   color: Colors.white,
                //   fontSize: 12,
                // ),
              ),
          ],
        ),
      ),
    );
  }
}

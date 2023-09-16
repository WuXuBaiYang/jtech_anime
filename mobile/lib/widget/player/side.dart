import 'package:flutter/material.dart';
import 'package:jtech_anime_base/base.dart';

/*
* 自定义播放器控制层-侧边
* @author wuxubaiyang
* @Time 2023/8/28 10:19
*/
class CustomPlayerControlsSide extends StatefulWidget {
  // 播放器控制器
  final CustomVideoPlayerController controller;

  // 当前是否为锁定状态
  final bool locked;

  const CustomPlayerControlsSide({
    super.key,
    required this.controller,
    this.locked = false,
  });

  @override
  State<StatefulWidget> createState() => _CustomPlayerControlsSideState();
}

/*
* 自定义播放器控制层-侧边-状态
* @author wuxubaiyang
* @Time 2023/8/28 10:19
*/
class _CustomPlayerControlsSideState extends State<CustomPlayerControlsSide> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLockAction(),
          ],
        ),
      ),
    );
  }

  // 构建锁定按钮
  Widget _buildLockAction() {
    final controller = widget.controller;
    return IconButton(
      icon: Icon(
          widget.locked ? FontAwesomeIcons.lock : FontAwesomeIcons.lockOpen),
      color: widget.locked ? kPrimaryColor : null,
      onPressed: () {
        controller.setControlVisible(true);
        controller.toggleScreenLocked();
      },
    );
  }
}

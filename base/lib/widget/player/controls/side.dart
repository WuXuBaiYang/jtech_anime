import 'package:flutter/material.dart';
import 'package:jtech_anime_base/base.dart';
import 'package:jtech_anime_base/widget/player/widgets/lock_button.dart';

/*
* 自定义播放器控制层-侧边
* @author wuxubaiyang
* @Time 2023/8/28 10:19
*/
class CustomPlayerControlsSide extends StatelessWidget {
  // 播放器控制器
  final CustomVideoPlayerController controller;

  // 是否展示锁定
  final bool showLock;

  const CustomPlayerControlsSide({
    super.key,
    required this.controller,
    this.showLock = true,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: _buildSideActions(),
    );
  }

  // 构建侧边按钮
  Widget _buildSideActions() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showLock) CustomPlayerLockButton(controller: controller),
        ],
      ),
    );
  }
}

import 'package:desktop/widget/player/progress.dart';
import 'package:flutter/material.dart';
import 'package:jtech_anime_base/base.dart';

/*
* 自定义播放器控制层-mini窗口状态
* @author wuxubaiyang
* @Time 2023/8/28 10:57
*/
class CustomPlayerControlsMini extends StatefulWidget {
  // 播放器控制器
  final CustomVideoPlayerController controller;

  const CustomPlayerControlsMini({
    super.key,
    required this.controller,
  });

  @override
  State<StatefulWidget> createState() => _CustomPlayerControlsMiniState();
}

/*
* 自定义播放器控制层-mini窗口-状态
* @author wuxubaiyang
* @Time 2023/8/28 10:57
*/
class _CustomPlayerControlsMiniState extends State<CustomPlayerControlsMini> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.75),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: CloseButton(
              onPressed: widget.controller.toggleMiniWindow,
            ),
          ),
          _buildPlayAction(),
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildProgressAction(),
          ),
        ],
      ),
    );
  }

  // 构建播放进度条
  Widget _buildProgressAction() {
    final controller = widget.controller;
    return CustomPlayerMiniProgress(
      controller: controller,
    );
  }

  // 构建底部状态播放按钮
  Widget _buildPlayAction() {
    final controller = widget.controller;
    return StreamBuilder<bool>(
      stream: controller.stream.playing,
      builder: (_, snap) {
        final playing = controller.state.playing;
        final icon = playing ? FontAwesomeIcons.pause : FontAwesomeIcons.play;
        return IconButton(
            icon: Icon(icon), onPressed: controller.resumeOrPause);
      },
    );
  }
}

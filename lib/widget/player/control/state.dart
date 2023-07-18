import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jtech_anime/widget/player/controller.dart';
import 'package:jtech_anime/widget/status_box.dart';

/*
* 自定义视频播放器，状态层
* @author wuxubaiyang
* @Time 2023/7/17 15:52
*/
class CustomVideoPlayerStateLayer extends StatefulWidget {
  // 控制器
  final CustomVideoPlayerController controller;

  // 占位组件
  final Widget? placeholder;

  const CustomVideoPlayerStateLayer({
    super.key,
    required this.controller,
    this.placeholder,
  });

  @override
  State<CustomVideoPlayerStateLayer> createState() =>
      _CustomVideoPlayerStateLayerState();
}

class _CustomVideoPlayerStateLayerState
    extends State<CustomVideoPlayerStateLayer> {
  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return ValueListenableBuilder<PlayerState>(
      valueListenable: controller,
      builder: (_, state, __) {
        switch (state) {
          case PlayerState.none: // 如果无状态则显示占位图
            return widget.placeholder ?? const SizedBox();
          case PlayerState.paused: // 暂停
          case PlayerState.ready2Play: // 准备播放
            return const Icon(FontAwesomeIcons.play, size: 45);
          case PlayerState.loading: // 正在加载视频
          case PlayerState.buffering: // 正在缓冲视频
            final text = {
              PlayerState.loading: '正在加载视频~',
              PlayerState.buffering: '',
            }[controller.value];
            return StatusBox(
              status: StatusBoxStatus.loading,
              title: Text(text ?? ''),
              color: Colors.white54,
              animSize: 30,
              space: 14,
            );
          default: // 其他则不显示
            return const SizedBox();
        }
      },
    );
  }
}

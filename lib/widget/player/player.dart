import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jtech_anime/widget/player/controller.dart';
import 'package:jtech_anime/widget/status_box.dart';
import 'package:video_player/video_player.dart';

/*
* 视频播放器
* @author wuxubaiyang
* @Time 2023/7/12 13:35
*/
class CustomVideoPlayer extends StatefulWidget {
  // 视频控制器
  final CustomVideoPlayerController controller;

  // 动作条组件集合
  final List<Widget> actions;

  // 标题
  final Widget? title;

  // 状态为空时的占位图
  final Widget? placeholder;

  const CustomVideoPlayer({
    super.key,
    required this.controller,
    this.actions = const [],
    this.placeholder,
    this.title,
  });

  @override
  State<StatefulWidget> createState() => _CustomVideoPlayerState();
}

/*
* 视频播放器-状态
* @author wuxubaiyang
* @Time 2023/7/12 13:55
*/
class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PlayerState>(
      valueListenable: widget.controller,
      builder: (_, state, __) {
        final controller = widget.controller;
        return Stack(
          alignment: Alignment.center,
          children: [
            _buildPlayerLayer(context, controller),
            _buildStateLayer(context, controller),
          ],
        );
      },
    );
  }

  // 构建播放器(最底层)
  Widget _buildPlayerLayer(
      BuildContext context, CustomVideoPlayerController controller) {
    final videoController = controller.videoController;
    if (videoController == null) return const SizedBox();
    return ValueListenableBuilder(
      valueListenable: controller.ratio,
      builder: (_, videoRatio, __) {
        final ratio = controller.getAspectRatio(context);
        return AspectRatio(
          aspectRatio: ratio,
          child: VideoPlayer(videoController),
        );
      },
    );
  }

  // 构建状态层
  Widget _buildStateLayer(
      BuildContext context, CustomVideoPlayerController controller) {
    // 如果是播放中则不显示状态
    if (controller.isPlaying) return const SizedBox();
    // 如果无状态则显示占位图
    if (controller.value == PlayerState.none) {
      return widget.placeholder ?? const SizedBox();
    }
    // 如果是暂停/准备播放则展示播放按钮
    if (controller.isPause || controller.isReady2Play) {
      return const Icon(FontAwesomeIcons.play);
    }
    // 展示其他状态
    const hintColor = Colors.white38;
    final text = {
      PlayerState.loading: '正在加载视频~',
      PlayerState.buffering: '正在缓冲视频~',
    }[controller.value];
    return StatusBox(
      status: StatusBoxStatus.loading,
      title: Text(text ?? ''),
      color: hintColor,
      animSize: 45,
    );
  }
}

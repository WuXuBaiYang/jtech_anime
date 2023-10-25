import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jtech_anime_base/manage/config.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'controller.dart';

/*
* 自定义视频播放器
* @author wuxubaiyang
* @Time 2023/8/19 14:30
*/
class CustomVideoPlayer extends StatefulWidget {
  // 控制器
  final CustomVideoPlayerController controller;

  // 控制层回调
  final VideoControlsBuilder? controls;

  const CustomVideoPlayer({
    super.key,
    required this.controller,
    this.controls,
  });

  @override
  State<StatefulWidget> createState() => _CustomVideoPlayerState();
}

/*
* 自定义视频播放器-状态
* @author wuxubaiyang
* @Time 2023/8/19 14:30
*/
class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  @override
  Widget build(BuildContext context) {
    return Video(
      controller: controller,
      controls: widget.controls,
      pauseUponEnteringBackgroundMode: true,
      resumeUponEnteringForegroundMode: true,
    );
  }

  // 缓存自定义控制器
  VideoController? _controller;

  // 获取控制器
  VideoController get controller =>
      _controller ??= (rootConfig.isNoPlayerContent && kDebugMode
              ? CustomVideoPlayerController()
              : widget.controller)
          .controller;
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jtech_anime_base/manage/config.dart';
import 'package:jtech_anime_base/tool/tool.dart';
import 'package:jtech_anime_base/widget/player/controls/controls_mobile.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'controls/controls_desktop.dart';
import 'controller.dart';

/*
* 自定义视频播放器
* @author wuxubaiyang
* @Time 2023/8/19 14:30
*/
class CustomVideoPlayer extends StatefulWidget {
  // 控制器
  final CustomVideoPlayerController controller;

  // 自定义样式
  final ThemeData? theme;

  // 标题
  final Widget? title;

  // 顶部leading
  final Widget? leading;

  // 副标题
  final Widget? subTitle;

  // 顶部按钮集合
  final List<Widget> topActions;

  // 底部按钮集合
  final List<Widget> bottomActions;

  // 缓冲状态大小
  final double? buffingSize;

  const CustomVideoPlayer({
    super.key,
    required this.controller,
    this.theme,
    this.title,
    this.leading,
    this.subTitle,
    this.buffingSize,
    this.topActions = const [],
    this.bottomActions = const [],
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
      controls: _adaptiveVideoControls,
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

  // 构建控制层
  Widget _adaptiveVideoControls(VideoState state) {
    if (isMobile) {
      return MobileCustomPlayerControls(
        theme: widget.theme,
        title: widget.title,
        leading: widget.leading,
        subTitle: widget.subTitle,
        topActions: widget.topActions,
        controller: widget.controller,
        buffingSize: widget.buffingSize,
        bottomActions: widget.bottomActions,
      );
    }
    if (isDesktop) {
      return DesktopCustomPlayerControls(
        theme: widget.theme,
        title: widget.title,
        leading: widget.leading,
        subTitle: widget.subTitle,
        topActions: widget.topActions,
        controller: widget.controller,
        buffingSize: widget.buffingSize,
        bottomActions: widget.bottomActions,
      );
    }
    return const SizedBox();
  }
}

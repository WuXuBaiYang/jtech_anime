import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jtech_anime_base/manage/config.dart';
import 'package:jtech_anime_base/widget/player/controls/controls_mobile.dart';
import 'package:jtech_anime_base/widget/screen_builder.dart';
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

  // 是否展示音量按钮
  final bool showVolume;

  // 是否展示倍速按钮
  final bool showSpeed;

  // 是否展示迷你屏幕按钮
  final bool showMiniScreen;

  // 是否展示全屏按钮
  final bool showFullScreen;

  // 是否展示进度条两侧的文本
  final bool showProgressText;

  // 是否展示时间
  final bool showTimer;

  const CustomVideoPlayer({
    super.key,
    required this.controller,
    this.theme,
    this.title,
    this.leading,
    this.subTitle,
    this.buffingSize,
    this.showSpeed = true,
    this.showVolume = true,
    this.showMiniScreen = true,
    this.showFullScreen = true,
    this.showProgressText = true,
    this.showTimer = true,
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
    return ScreenBuilder(
      builder: (_) => DesktopCustomPlayerControls(
        theme: widget.theme,
        title: widget.title,
        leading: widget.leading,
        subTitle: widget.subTitle,
        topActions: widget.topActions,
        controller: widget.controller,
        buffingSize: widget.buffingSize,
        bottomActions: widget.bottomActions,
        showVolume: widget.showVolume,
        showSpeed: widget.showSpeed,
        showMiniScreen: widget.showMiniScreen,
        showFullScreen: widget.showFullScreen,
        showProgressText: widget.showProgressText,
        showTimer: widget.showTimer,
      ),
      mobile: (_) => MobileCustomPlayerControls(
        theme: widget.theme,
        title: widget.title,
        leading: widget.leading,
        subTitle: widget.subTitle,
        topActions: widget.topActions,
        controller: widget.controller,
        buffingSize: widget.buffingSize,
        bottomActions: widget.bottomActions,
        showVolume: widget.showVolume,
        showSpeed: widget.showSpeed,
        showProgressText: widget.showProgressText,
        showTimer: widget.showTimer,
      ),
    );
  }
}

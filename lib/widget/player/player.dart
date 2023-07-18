import 'package:flutter/material.dart';
import 'package:jtech_anime/common/notifier.dart';
import 'package:jtech_anime/widget/listenable_builders.dart';
import 'package:video_player/video_player.dart';
import 'control/control.dart';
import 'control/gesture.dart';
import 'control/hint.dart';
import 'control/layer.dart';
import 'control/lock.dart';
import 'control/state.dart';
import 'controller.dart';

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

  // 弹出层背景色
  final Color overlayColor;

  // 主色调
  final Color? primaryColor;

  const CustomVideoPlayer({
    super.key,
    required this.controller,
    this.title,
    this.placeholder,
    this.primaryColor,
    this.actions = const [],
    this.overlayColor = Colors.black26,
  });

  @override
  State<StatefulWidget> createState() => _CustomVideoPlayerState();
}

/*
* 视频播放器-状态
* @author wuxubaiyang
* @Time 2023/7/12 13:55
*/
class _CustomVideoPlayerState extends State<CustomVideoPlayer>
    with CustomVideoPlayerLayer {
  // 锁屏状态显示隐藏
  final showLock = ValueChangeNotifier<bool>(false);

  // 控制组件显示隐藏
  final showControl = ValueChangeNotifier<bool>(false);

  // 亮度组件显示隐藏
  final showBrightness = ValueChangeNotifier<bool>(false);

  // 音量组件显示隐藏
  final showVolume = ValueChangeNotifier<bool>(false);

  // 倍速组件显示隐藏
  final showSpeed = ValueChangeNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _themeData,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildPlayerLayer(context),
          _buildStateLayer(),
          Positioned.fill(child: _buildGestureLayer()),
          Positioned.fill(child: _buildHintLayer()),
          Positioned.fill(child: _buildControlLayer()),
          Positioned.fill(child: _buildLockLayer()),
        ],
      ),
    );
  }

  // 样式配置
  ThemeData get _themeData => ThemeData.dark(useMaterial3: true).copyWith(
        cardTheme: const CardTheme(elevation: 0),
        colorScheme: widget.primaryColor != null
            ? ColorScheme.dark(primary: widget.primaryColor!)
            : null,
      );

  // 构建播放器层
  Widget _buildPlayerLayer(BuildContext context) {
    return ValueListenableBuilder2<PlayerState, PlayerRatio>(
      first: widget.controller,
      second: widget.controller.ratio,
      builder: (_, state, ratio, __) {
        final videoController = widget.controller.videoController;
        if (videoController == null) return const SizedBox();
        return AspectRatio(
          aspectRatio: widget.controller.getAspectRatio(context),
          child: VideoPlayer(videoController),
        );
      },
    );
  }

  // 构建状态层
  Widget _buildStateLayer() {
    return CustomVideoPlayerStateLayer(
      controller: widget.controller,
      placeholder: widget.placeholder,
    );
  }

  // 构建手势操作层
  Widget _buildGestureLayer() {
    return CustomVideoPlayerGestureLayer(
      controller: widget.controller,
      onTap: () => toggleShow(showControl),
      onSpeed: (v, _) => showProtrudeView(showSpeed, [showControl], v),
      onVolume: (v, _) => showProtrudeView(showVolume, [showControl], v),
      onBrightness: (v, _) =>
          showProtrudeView(showBrightness, [showControl], v),
    );
  }

  // 构建提示消息层
  Widget _buildHintLayer() {
    return CustomVideoPlayerHintLayer(
      controller: widget.controller,
      overlayColor: widget.overlayColor,
      showSpeed: showSpeed,
      showVolume: showVolume,
      showBrightness: showBrightness,
    );
  }

  // 构建控制组件
  Widget _buildControlLayer() {
    return buildAnimeShow(
      showControl,
      CustomVideoPlayerControlLayer(
        title: widget.title,
        actions: widget.actions,
        controller: widget.controller,
        primaryColor: widget.primaryColor,
        overlayColor: widget.overlayColor,
        onPlay: () => show(showControl),
        onNext: () => show(showControl),
        onRatio: () => show(showControl),
        onSeek: () => show(showControl,
            throttleDelay: const Duration(milliseconds: 2000)),
        onLock: () {
          showControl.setValue(false);
          show(showLock);
        },
      ),
    );
  }

  // 构建锁屏层
  Widget _buildLockLayer() {
    return buildAnimeShow(
      showLock,
      CustomVideoPlayerLockLayer(
        controller: widget.controller,
        onTap: () => toggleShow(showLock),
        onUnlock: () {
          showLock.setValue(false);
          show(showControl);
        },
      ),
    );
  }
}

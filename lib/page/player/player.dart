import 'dart:io';

import 'package:flutter/material.dart';
import 'package:jtech_anime/common/notifier.dart';
import 'package:video_player/video_player.dart';

/*
* 视频播放器
* @author wuxubaiyang
* @Time 2023/7/12 13:35
*/
class CustomVideoPlayer extends StatefulWidget {
  const CustomVideoPlayer({super.key});

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
    return SizedBox();
  }
}

/*
* 播放器控制器
* @author wuxubaiyang
* @Time 2023/7/16 14:08
*/
class CustomVideoPlayerController extends ValueChangeNotifier<PlayerState> {
  // 视频播放器控制器
  VideoPlayerController? _controller;

  CustomVideoPlayerController() : super(PlayerState.none);

  // 播放网络视频
  Future<void> playNet(String url,
      {Map<String, String> headers = const {}, bool autoPlay = true}) {
    final controller =
        VideoPlayerController.networkUrl(Uri.parse(url), httpHeaders: headers);
    return _play(controller, autoPlay: autoPlay);
  }

  // 播放本地视频
  Future<void> playFile(File file,
      {Map<String, String> headers = const {}, bool autoPlay = true}) {
    final controller = VideoPlayerController.file(file, httpHeaders: headers);
    return _play(controller, autoPlay: autoPlay);
  }

  // 播放视频
  Future<void> _play(VideoPlayerController controller,
      {bool autoPlay = true}) async {
    // 切换播放状态并销毁上一个控制器
    setValue(PlayerState.loading);
    _controller?.dispose();
    // 初始化播放器并监听状态,如果初始化成功则替换现有播放器并开始播放
    await controller.initialize();
    if (!controller.value.isInitialized) {
      return setValue(PlayerState.none);
    }
    setValue(PlayerState.initialized);
    _controller = controller;
    if (!autoPlay) return;
    await controller.play();
    if (controller.value.isPlaying) {
      setValue(PlayerState.playing);
    }
  }

  // 监听播放进度
  void addProgressListener(){
    // _controller?.value.isPlaying
  }

  // 判断是否正在播放
  bool get isPlaying => value == PlayerState.playing;

  // 判断是否正在加载
  bool get isLoading => value == PlayerState.loading;

  // 判断是否已初始化
  bool get isInitialized => value == PlayerState.initialized;

  @override
  void dispose() {
    super.dispose();
    // 销毁播放控制器
    _controller?.dispose();
  }
}

/*
* 播放状态
* @author wuxubaiyang
* @Time 2023/7/16 14:08
*/
enum PlayerState { playing, loading, initialized, none }

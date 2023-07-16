import 'dart:io';

import 'package:flutter/material.dart';
import 'package:jtech_anime/common/notifier.dart';
import 'package:jtech_anime/tool/date.dart';
import 'package:screen_brightness/screen_brightness.dart';
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

  // 播放进度
  final progress = ValueChangeNotifier<Duration>(Duration.zero);

  // 音量
  final volume = ValueChangeNotifier<double>(1);

  // 亮度
  final brightness = ValueChangeNotifier<double>(1);

  // 播放速度
  final playbackSpeed = ValueChangeNotifier<double>(1);

  CustomVideoPlayerController() : super(PlayerState.none);

  // 获取总时长
  Duration get total => _controller?.value.duration ?? Duration.zero;

  // 获取当前视频比例
  double get aspectRatio => _controller?.value.aspectRatio ?? 0;

  // 获取当前视频的尺寸
  Size get size => _controller?.value.size ?? Size.zero;

  // 播放网络视频
  Future<void> playNet(String url,
      {Map<String, String> headers = const {}, bool autoPlay = true}) {
    _controller?.value.volume;
    _controller?.value.buffered;
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
    // 停止播放释放控制器
    await stop();
    setValue(PlayerState.loading);
    // 初始化设置
    await _setInitVideo(controller);
    // 初始化播放器并监听状态,如果初始化成功则替换现有播放器并开始播放
    await controller.initialize();
    if (!controller.value.isInitialized) {
      return setValue(PlayerState.none);
    }
    setValue(PlayerState.ready2Play);
    _controller = controller;
    if (!autoPlay) return;
    await controller.play();
    if (!controller.value.isPlaying) return;
    setValue(PlayerState.playing);
  }

  // 设置监听播放状态
  Future<void> _setInitVideo(VideoPlayerController controller) async {
    // 设置当前屏幕亮度
    final screen = ScreenBrightness();
    brightness.setValue(await screen.current);
    // 监听播放
    controller.addListener(() {
      final v = controller.value;
      // 监听回调参数
      volume.setValue(v.volume);
      progress.setValue(v.position);
      playbackSpeed.setValue(v.playbackSpeed);
    });
  }

  // 暂停播放
  Future<void> pause() async {
    if (_controller == null) return;
    await _controller!.pause();
    if (_controller!.value.isPlaying) return;
    setValue(PlayerState.paused);
  }

  // 恢复播放
  Future<void> resume() async {
    if (_controller == null) return;
    await _controller!.play();
    if (!_controller!.value.isPlaying) return;
    setValue(PlayerState.playing);
  }

  // 停止播放
  Future<void> stop() async {
    // 释放视频资源并清空
    await _controller?.dispose();
    setValue(PlayerState.none);
    _controller = null;
    // 重置所有参数
    progress.setValue(Duration.zero);
    playbackSpeed.setValue(1);
    brightness.setValue(1);
    volume.setValue(1);
  }

  // 更新播放进度
  Future<void> setProgress(Duration progress) async {
    if (_controller == null) return;
    if (progress.greaterThan(total)) return;
    await _controller!.seekTo(progress);
  }

  // 更新音量
  Future<void> setVolume(double volume) async {
    if (_controller == null) return;
    await _controller!.setVolume(volume);
  }

  // 设置亮度
  Future<void> setBrightness(double value) async {
    final screen = ScreenBrightness();
    await screen.setScreenBrightness(value.clamp(0, 1));
    brightness.setValue(await screen.current);
  }

  // 设置播放进度
  Future<void> setPlaybackSpeed(double speed) async {
    if (_controller == null) return;
    _controller!.setPlaybackSpeed(speed);
  }

  // 判断是否正在加载
  bool get isLoading => value == PlayerState.loading;

  // 判断是否已可以播放
  bool get ready2Play => value == PlayerState.ready2Play;

  // 判断是否已初始化完成
  bool get isInitialized => _controller?.value.isInitialized ?? false;

  // 判断是否正在播放
  bool get isPlaying => value == PlayerState.playing;

  // 判断是否暂停
  bool get isPause => value == PlayerState.paused;

  @override
  void dispose() {
    super.dispose();
    // 销毁播放控制器
    stop();
  }
}

/*
* 播放状态
* @author wuxubaiyang
* @Time 2023/7/16 14:08
*/
enum PlayerState { loading, ready2Play, playing, paused, none }

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:jtech_anime/common/notifier.dart';
import 'package:jtech_anime/tool/date.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:video_player/video_player.dart';

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

  // 播放器视频比例
  final ratio = ValueChangeNotifier<PlayerRatio>(PlayerRatio.normal);

  // 锁屏状态
  final locked = ValueChangeNotifier<bool>(false);

  CustomVideoPlayerController() : super(PlayerState.none);

  // 获取播放器控制器
  VideoPlayerController? get videoController => _controller;

  // 获取总时长
  Duration get total => _controller?.value.duration ?? Duration.zero;

  // 获取当前视频比例(根据当前比例状态判断)
  double getAspectRatio(BuildContext context) {
    switch (ratio.value) {
      case PlayerRatio.normal: // 普通
        return _controller?.value.aspectRatio ?? 0;
      case PlayerRatio.fill: // 填充全屏
        final size = MediaQuery.of(context).size;
        return size.width / size.height;
    }
  }

  // 获取当前视频的尺寸
  Size get size => _controller?.value.size ?? Size.zero;

  // 监听播放进度
  void addProgressListener(VoidCallback listener) {
    VideoPlayerController? c;
    addListener(() {
      c ??= _controller?..addListener(listener);
      if (_controller == null) c = null;
    });
  }

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
    // 设置状态并判断是否开启自动播放
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
    // 设置当前音量
    FlutterVolumeController.showSystemUI = false;
    final value = await FlutterVolumeController.getVolume();
    volume.setValue(value ?? 0.0);
    // 监听播放
    controller.addListener(() {
      final v = controller.value;
      // 监听回调参数
      progress.setValue(v.position);
      playbackSpeed.setValue(v.playbackSpeed);
      // 设置状态
      setValue(v.isBuffering
          ? PlayerState.buffering
          : (v.isPlaying ? PlayerState.playing : PlayerState.paused));
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
    setValue(PlayerState.none);
    _controller?.dispose();
    _controller = null;
    // 重置所有参数
    progress.setValue(Duration.zero);
    playbackSpeed.setValue(1);
  }

  // 更新播放进度
  Future<void> setProgress(Duration progress) async {
    if (_controller == null) return;
    if (progress.greaterThan(total)) return;
    await _controller!.seekTo(progress);
  }

  // 更新音量
  Future<void> setVolume(double value) async {
    FlutterVolumeController.setVolume(value.clamp(0, 1));
    volume.setValue(value);
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
    await _controller!.setPlaybackSpeed(speed);
  }

  // 设置视频比例
  void setVideoRatio(PlayerRatio value) => ratio.setValue(value);

  // 设置锁屏状态
  void setLocked(bool value) => locked.setValue(value);

  // 判断是否正在加载
  bool get isLoading => value == PlayerState.loading;

  // 判断是否已可以播放
  bool get ready2Play => value == PlayerState.ready2Play;

  // 判断是否已初始化完成
  bool get isInitialized => _controller?.value.isInitialized ?? false;

  // 判断是否正在播放
  bool get isPlaying => value == PlayerState.playing;

  // 判断是否准备播放
  bool get isReady2Play => value == PlayerState.ready2Play;

  // 判断是否暂停
  bool get isPause => value == PlayerState.paused;

  // 判断是否缓冲中
  bool get isBuffering => value == PlayerState.buffering;

  // 判断比例是否为满屏
  bool get isRatioFill => ratio.value == PlayerRatio.fill;

  // 判断是否为本地视频
  bool get isLocalFile => _controller?.dataSourceType == DataSourceType.file;

  // 判断是否为网络视频
  bool get isNetwork => _controller?.dataSourceType == DataSourceType.network;

  @override
  void dispose() {
    // 销毁播放控制器
    stop();
    super.dispose();
  }
}

/*
* 播放状态
* @author wuxubaiyang
* @Time 2023/7/16 14:08
*/
enum PlayerState { loading, ready2Play, buffering, playing, paused, none }

/*
* 比例切换状态
* @author wuxubaiyang
* @Time 2023/7/17 9:04
*/
enum PlayerRatio { normal, fill }

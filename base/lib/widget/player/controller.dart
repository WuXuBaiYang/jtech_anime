import 'dart:async';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:jtech_anime_base/base.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

/*
* 自定义视频播放器控制器
* @author wuxubaiyang
* @Time 2023/8/19 14:31
*/
class CustomVideoPlayerController extends ValueChangeNotifier<VideoCache?> {
  // 播放器
  final _player = Player();

  // 是否展示控制
  final controlVisible = ValueChangeNotifier<bool>(false);

  // 全屏按钮控制
  final controlFullscreen = ValueChangeNotifier<bool>(false);

  // 屏幕锁定状态
  final screenLocked = ValueChangeNotifier<bool>(false);

  // 小窗口模式
  final miniWindow = ValueChangeNotifier<bool>(false);

  // 屏幕亮度控制（0-1）
  final screenBrightness = ValueChangeNotifier<double>(1);

  // 音量控制（0-1）
  final volume = ValueChangeNotifier<double>(0.3);

  // 控制器
  late final VideoController controller = VideoController(_player);

  CustomVideoPlayerController({
    VideoCache? initialVideo,
    bool autoPlay = true,
  }) : super(initialVideo) {
    // 禁止展示系统音量控制
    FlutterVolumeController.updateShowSystemUI(false);
    // 获取当前音量
    FlutterVolumeController.getVolume().then((v) {
      volume.setValue(v ?? 0.3);
    });
    // 监听音量变化并设置系统音量
    volume.addListener(() {
      FlutterVolumeController.setVolume(volume.value);
    });
    // 如果存在初始化视频，则加载并播放
    if (initialVideo != null) play(initialVideo.playUrl, autoPlay);
  }

  // 获取状态控制
  PlayerStream get stream => _player.stream;

  // 获取播放状态
  PlayerState get state => _player.state;

  // 计时器管理控制组件的显隐时间
  Timer? _timer;

  // 销毁定时器
  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  // 获取当前播放进度
  double get progress =>
      state.position.inMilliseconds / state.duration.inMilliseconds;

  // 切换控制组件
  void setControlVisible(bool visible, {bool ongoing = false}) {
    controlVisible.setValue(visible);
    _cancelTimer();
    if (!visible || ongoing) return;
    _timer = Timer(const Duration(milliseconds: 2400), () {
      controlVisible.setValue(false);
      _cancelTimer();
    });
  }

  // 获取当前小窗口状态
  bool get isMiniWindow => miniWindow.value;

  // 切换小窗口状态
  void toggleMiniWindow() => setMiniWindow(!miniWindow.value);

  // 设置小窗口状态
  void setMiniWindow(bool mini) => miniWindow.setValue(mini);

  // 获取当前锁屏状态
  bool get isScreenLocked => screenLocked.value;

  // 切换锁定状态
  void toggleScreenLocked() => setScreenLocked(!screenLocked.value);

  // 设置锁定状态
  void setScreenLocked(bool locked) => screenLocked.setValue(locked);

  // 获取当前全屏状态
  bool get isFullscreen => controlFullscreen.value;

  // 切换全屏状态
  void toggleFullscreen() => setFullscreen(!controlFullscreen.value);

  // 设置全屏状态
  void setFullscreen(bool fullscreen) => controlFullscreen.setValue(fullscreen);

  // 获取当前播放进度
  Duration get currentPosition => state.position;

  // 获取当前视频总时长
  Duration get currentDuration => state.duration;

  // 跳转到播放进度
  Future<Duration> seekTo(Duration duration) async {
    final value = duration.inMilliseconds;
    final max = state.duration.inMilliseconds;
    duration = Duration(milliseconds: range(value, 0, max));
    await _player.seek(duration);
    return state.position;
  }

  // 快进播放进度
  Future<Duration> seekForward(
          [Duration duration = const Duration(seconds: 3)]) =>
      seekTo(state.position + duration);

  // 快进播放进度
  Future<Duration> seekBackward(
          [Duration duration = const Duration(seconds: 3)]) =>
      seekTo(state.position - duration);

  // 获取当前播放倍速
  double get currentRate => state.rate;

  // 设置播放倍速(0.5-3)
  Future<double> setRate(double rate) async {
    await _player.setRate(range(rate, 0.5, 3));
    return state.rate;
  }

  // 获取当前屏幕亮度
  double get currentBrightness => screenBrightness.value;

  // 设置屏幕亮度(0-1,最暗到最亮)
  Future<double> setBrightness(double brightness) async {
    screenBrightness.setValue(range(brightness, 0, 1));
    return screenBrightness.value;
  }

  // 增加屏幕亮度
  Future<double> brightnessRaise([double step = 0.05]) =>
      setBrightness(screenBrightness.value + step);

  // 降低屏幕亮度
  Future<double> brightnessLower([double step = 0.05]) =>
      setBrightness(screenBrightness.value - step);

  // 获取当前音量
  double get currentVolume => volume.value;

  // 设置音量(0-1)
  Future<double> setVolume(double value) async {
    volume.setValue(range(value, 0, 1));
    return currentVolume;
  }

  // 增加音量
  Future<double> volumeRaise([double step = 0.15]) =>
      setVolume(currentVolume + step);

  // 降低音量
  Future<double> volumeLower([double step = 0.15]) =>
      setVolume(currentVolume - step);

  // 加载视频并播放
  Future<void> play(String uri, [bool autoPlay = true]) =>
      _player.open(Media(uri), play: autoPlay);

  // 增加视频到视频队列
  Future<void> playlist(List<String> uris, [bool autoPlay = true]) => _player
      .open(Playlist(uris.map((e) => Media(e)).toList()), play: autoPlay);

  // 切换播放暂停状态
  Future<bool> resumeOrPause() async {
    await _player.playOrPause();
    return state.playing;
  }

  // 恢复播放
  Future<void> resume() => _player.play();

  // 暂停播放
  Future<void> pause() => _player.pause();

  // 停止播放
  Future<void> stop() => _player.stop();

  // 播放队列中的下一条视频
  Future<void> next() => _player.next();

  // 播放队列中的上一条视频
  Future<void> previous() => _player.previous();

  // 跳转到播放列表的指定位置
  Future<void> jumpTo(int index) => _player.jump(index);

  @override
  void dispose() {
    // 销毁播放器
    _player.dispose();
    super.dispose();
  }
}

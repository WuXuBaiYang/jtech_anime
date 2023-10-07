import 'dart:async';
import 'package:jtech_anime_base/common/notifier.dart';
import 'package:jtech_anime_base/model/database/video_cache.dart';
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

  // 控制器
  late final VideoController controller = VideoController(_player);

  CustomVideoPlayerController({
    VideoCache? initialVideo,
    bool autoPlay = true,
  }) : super(initialVideo) {
    if (initialVideo == null) return;
    // 如果存在初始化视频，则加载并播放
    play(initialVideo.playUrl, autoPlay);
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

  // 切换锁定状态
  void toggleScreenLocked() => setScreenLocked(!screenLocked.value);

  // 设置锁定状态
  void setScreenLocked(bool locked) => screenLocked.setValue(locked);

  // 切换全屏状态
  void toggleFullscreen() => setFullscreen(!controlFullscreen.value);

  // 设置全屏状态
  void setFullscreen(bool fullscreen) => controlFullscreen.setValue(fullscreen);

  // 跳转到播放进度
  Future<void> seekTo(Duration duration) async {
    if (duration > state.duration || duration < Duration.zero) return;
    return _player.seek(duration);
  }

  // 快进播放进度
  Future<void> seekForward(
      {Duration duration = const Duration(seconds: 3)}) async {
    final current = state.position;
    final target = current + duration;
    if (target > state.duration) return;
    return _player.seek(target);
  }

  // 快进播放进度
  Future<void> seekBackward(
      {Duration duration = const Duration(seconds: 3)}) async {
    final current = state.position;
    final target = current - duration;
    if (target < Duration.zero) return;
    return _player.seek(target);
  }

  // 设置播放倍速
  Future<void> setRate(double rate) async {
    if (rate < 0 || rate > 5) return;
    return _player.setRate(rate);
  }

  // 增加倍速
  Future<void> rateRaise([double step = 1]) => setRate(state.rate + step);

  // 降低倍速
  Future<void> rateLower([double step = 1]) => setRate(state.rate - step);

  // 设置音量
  Future<void> setVolume(double volume) async {
    if (volume > 100 || volume < 0) return;
    return _player.setVolume(volume);
  }

  // 增加音量
  Future<void> volumeRaise([double step = 0.1]) =>
      setVolume(state.volume + step * 100);

  // 降低音量
  Future<void> volumeLower([double step = 0.1]) =>
      setVolume(state.volume - step * 100);

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

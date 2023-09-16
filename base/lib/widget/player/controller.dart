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
  Future<void> seekTo(Duration duration) => _player.seek(duration);

  // 设置播放倍速
  Future<void> setRate(double rate) => _player.setRate(rate);

  // 加载视频并播放
  Future<void> play(String uri, [bool autoPlay = true]) =>
      _player.open(Media(uri), play: autoPlay);

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

  @override
  void dispose() {
    // 销毁播放器
    _player.dispose();
    super.dispose();
  }
}

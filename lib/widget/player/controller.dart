import 'package:jtech_anime/common/notifier.dart';
import 'package:jtech_anime/model/database/video_cache.dart';
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

  // 控制器
  late final VideoController controller = VideoController(_player);

  // 屏幕锁定状态
  final screenLocked = ValueChangeNotifier<bool>(false);

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

  // 切换锁定状态
  void toggleScreenLock([bool? locked]) =>
      screenLocked.setValue(locked ?? !screenLocked.value);

  // 跳转到播放进度
  Future<void> seekTo(Duration duration) => _player.seek(duration);

  // 设置播放倍速
  Future<void> setRate(double rate) => _player.setRate(rate);

  // 设置音量
  Future<void> setVolume(double volume) => _player.setVolume(volume);

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

import 'dart:async';
import 'package:volume_controller/volume_controller.dart';

/*
* 音量控制工具
* @author wuxubaiyang
* @Time 2023/8/28 14:46
*/
class VolumeTool {
  // 控制器
  static final _controller = VolumeController();

  // 数值变化
  static final _streamController = StreamController<double>.broadcast();

  // 当前音量
  static double _currentVolume = 0;

  // 初始化设置
  static void setup() {
    // 不显示系统音量提示
    _controller.showSystemUI = false;
    // 获取当前音量
    _controller.getVolume().then((v) => _currentVolume = v);
  }

  // 获取当前音量
  static Future<double> current() async => _currentVolume;

  // 设置音量
  static Future<void> set(double volume) async {
    if (volume < 0 || volume > 1) return;
    _currentVolume = volume;
    _controller.setVolume(_currentVolume);
    _streamController.sink.add(_currentVolume);
  }

  // 设置最大音量
  static void max() => _controller.maxVolume();

  // 设置静音
  static void mute() => _controller.muteVolume();

  // 获取流
  static Stream<double> get stream => _streamController.stream;
}

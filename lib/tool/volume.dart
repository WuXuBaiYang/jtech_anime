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

  // 初始化设置
  static void setup() {
    // 不显示系统音量提示
    _controller.showSystemUI = false;
    // 监听音量变化
    _controller.listener(_streamController.sink.add);
  }

  // 获取当前音量
  static Future<double> current() => _controller.getVolume();

  // 设置音量
  static void set(double volume) => _controller.setVolume(volume);

  // 设置最大音量
  static void max() => _controller.maxVolume();

  // 设置静音
  static void mute() => _controller.muteVolume();

  // 获取流
  static Stream<double> get stream => _streamController.stream;
}

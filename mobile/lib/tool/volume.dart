import 'dart:async';

import 'package:flutter_volume_controller/flutter_volume_controller.dart';

/*
* 音量控制工具
* @author wuxubaiyang
* @Time 2023/8/28 14:46
*/
class VolumeTool {
  // 数值变化
  static final _streamController = StreamController<double>.broadcast();

  // 当前音量
  static double _currentVolume = 0;

  // 初始化设置
  static void setup() {
    // 不显示系统音量提示
    FlutterVolumeController.showSystemUI = true;
    // 获取当前音量
    FlutterVolumeController.getVolume().then(
      (v) => _currentVolume = v ?? 0,
    );
    // 监听音量变化
    FlutterVolumeController.addListener((v) {
      _streamController.sink.add(v);
      _currentVolume = v;
    });
  }

  // 获取当前音量
  static Future<double> current() async => _currentVolume;

  // 设置音量
  static Future<void> set(double volume) async {
    if (volume < 0 || volume > 1) return;
    _currentVolume = volume;
    _streamController.sink.add(_currentVolume);
    FlutterVolumeController.setVolume(_currentVolume);
  }

  // 设置静音
  static void mute() => FlutterVolumeController.setMute(true);

  // 获取流
  static Stream<double> get stream => _streamController.stream;
}

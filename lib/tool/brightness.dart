import 'dart:async';
import 'package:screen_brightness/screen_brightness.dart';

/*
* 屏幕亮度控制工具
* @author wuxubaiyang
* @Time 2023/8/28 14:46
*/
class BrightnessTool {
  // 控制器
  static final _controller = ScreenBrightness();

  // 获取当前亮度
  static Future<double> current() => _controller.current;

  // 设置亮度
  static Future<void> set(double brightness) =>
      _controller.setScreenBrightness(brightness);

  // 获取流
  static Stream<double> get stream =>
      ScreenBrightness().onCurrentBrightnessChanged;
}

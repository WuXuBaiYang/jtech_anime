import 'dart:async';
import 'package:flutter/animation.dart';

/*
* 防抖
* @author wuxubaiyang
* @Time 2023/7/18 13:29
*/
class Debounce {
  // 防抖方法表
  static final _debounce = {};

  // 防抖
  static void c(Function() func, String key,
      {Duration delay = const Duration(milliseconds: 2000)}) {
    Timer? timer = _debounce[key];
    if (timer?.isActive ?? false) {
      _debounce.remove(key);
      timer?.cancel();
    }
    _debounce[key] = Timer(delay, func);
  }

  // 防抖方法
  static VoidCallback? click(Function() func, String key,
      {Duration delay = const Duration(milliseconds: 2000)}) {
    return () => c(func, key, delay: delay);
  }

  // 清除防抖
  static void clear(String key) {
    Timer? timer = _debounce[key];
    if (timer?.isActive ?? false) {
      _debounce.remove(key);
      timer?.cancel();
    }
  }
}

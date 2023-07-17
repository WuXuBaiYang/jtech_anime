import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jtech_anime/common/notifier.dart';

/*
* 自定义视频播放器，分层基类
* @author wuxubaiyang
* @Time 2023/7/17 15:56
*/
mixin class CustomVideoPlayerLayer {
  // 显示隐藏的动画间隔
  final animeDuration = const Duration(milliseconds: 90);

  // 展示组件并在一定时间后隐藏
  void show(ValueChangeNotifier<bool> notifier) {
    if (notifier.value) {
      notifier.setValue(false);
    } else {
      notifier.setValue(true);
      _debounce(() => notifier.setValue(false));
    }
  }

  // 构建可控显示隐藏组件
  Widget buildAnimeShow(ValueChangeNotifier<bool> notifier, Widget child) {
    return ValueListenableBuilder<bool>(
      valueListenable: notifier,
      builder: (_, show, __) {
        return AnimatedOpacity(
          opacity: show ? 1 : 0,
          duration: animeDuration,
          child: child,
        );
      },
    );
  }

  // 展示突出组件（展示突出组件并隐藏其他组件）
  void showProtrudeView(ValueChangeNotifier<bool> notifier,
      List<ValueChangeNotifier<bool>> hides, bool show) {
    // 展示重点组件
    notifier.setValue(show);
    // 遍历要隐藏的其他组件
    for (var e in hides) {
      e.setValue(false);
    }
  }

  // 防抖时间
  Timer? _timer;

  // 函数防抖
  void _debounce(Function func,
      [Duration delay = const Duration(milliseconds: 2000)]) {
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
    }
    _timer = Timer(delay, () => func.call());
  }
}

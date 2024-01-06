import 'dart:async';
import 'dart:ui';

/*
* 节流
* @author wuxubaiyang
* @Time 2023/7/18 13:29
*/
class Throttle {
  // 节流方法
  static final _throttle = <String>{};

  // 节流
  static void c(Function() func, String key,
      {Duration delay = const Duration(milliseconds: 2000)}) async {
    if (_throttle.contains(key)) return;
    _throttle.add(key);
    func.call();
    await Future.delayed(delay);
    _throttle.remove(key);
  }

  // 节流方法
  static VoidCallback? click(Function() func, String key,
      {Duration delay = const Duration(milliseconds: 2000)}) {
    return () => c(func, key, delay: delay);
  }

  // 清除节流
  static void clear(String key) => _throttle.remove(key);
}

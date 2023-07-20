import 'dart:async';
import 'dart:ui';

/*
* 节流
* @author wuxubaiyang
* @Time 2023/7/18 13:29
*/
class Throttle {
  // 节流方法表
  static final _throttleMap = {};

  // 节流
  static void c(void Function() func,
      {String? key, Duration delay = const Duration(milliseconds: 2000)}) {
    key ??= '${func.hashCode}';
    Timer? timer = _throttleMap[key];
    if (timer != null) return;
    _throttleMap[key] = Timer(delay, () {
      _throttleMap.remove(key);
      timer?.cancel();
    });
    func.call();
  }

  // 节流方法
  static VoidCallback? f(void Function() func,
      {String? key, Duration delay = const Duration(milliseconds: 2000)}) {
    return () => c(func, key: key, delay: delay);
  }
}

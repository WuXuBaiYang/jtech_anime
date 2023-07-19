import 'dart:async';

/*
* 节流
* @author wuxubaiyang
* @Time 2023/7/18 13:29
*/
class Throttle {
  // 节流方法表
  static final _throttleMap = {};

  // 节流
  static void c(Function func,
      {String? key, Duration delay = const Duration(seconds: 2)}) {
    key ??= '${func.hashCode}';
    Timer? timer = _throttleMap[key];
    if (timer != null) return;
    timer = Timer(delay, () {
      _throttleMap.remove(key);
      timer?.cancel();
    });
    func.call();
  }
}

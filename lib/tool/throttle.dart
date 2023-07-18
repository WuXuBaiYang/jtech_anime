import 'dart:async';

/*
* 节流
* @author wuxubaiyang
* @Time 2023/7/18 13:29
*/
class Throttle {
  // 节流
  Timer? _throttleTimer;

  // 节流
  void call(Function func,
      [Duration delay = const Duration(milliseconds: 2000)]) {
    if (_throttleTimer != null) return;
    _throttleTimer = Timer(delay, () {
      _throttleTimer?.cancel();
      _throttleTimer = null;
    });
    func.call();
  }
}

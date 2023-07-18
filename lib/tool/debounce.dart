import 'dart:async';

/*
* 防抖
* @author wuxubaiyang
* @Time 2023/7/18 13:29
*/
class Debounce {
  // 防抖
  Timer? _debounceTimer;

  // 防抖
  void call(Function func,
      [Duration delay = const Duration(milliseconds: 2000)]) {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer?.cancel();
    }
    _debounceTimer = Timer(delay, () => func.call());
  }
}

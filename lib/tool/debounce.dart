import 'dart:async';

/*
* 防抖
* @author wuxubaiyang
* @Time 2023/7/18 13:29
*/
class Debounce {
  // 防抖方法表
  static final _debounceMap = {};

  // 防抖
  static void c(void Function() func,
      {String? key, Duration delay = const Duration(milliseconds: 2000)}) {
    key ??= '${func.hashCode}';
    Timer? timer = _debounceMap[key];
    if (timer?.isActive ?? false) {
      _debounceMap.remove(key);
      timer?.cancel();
    }
    _debounceMap[key] = Timer(delay, func);
  }
}

import 'package:jtech_anime/common/provider.dart';
import 'package:window_manager/window_manager.dart';

/*
* 窗口提供者
* @author wuxubaiyang
* @Time 2023/11/26 18:56
*/
class WindowProvider extends BaseProvider with WindowListener {
  // 窗口最大化状态
  bool _maximized = false;

  // 窗口是否最大化
  bool get maximized => _maximized;

  WindowProvider(super.context) {
    // 监听窗口变化
    windowManager.addListener(this);
  }

  // 最大化窗口
  void maximize({bool vertically = false}) {
    _maximized = true;
    windowManager.maximize(vertically: vertically);
    notifyListeners();
  }

  // 最小化窗口
  void unMaximize() {
    _maximized = false;
    windowManager.unmaximize();
    notifyListeners();
  }

  @override
  void onWindowMaximize() => maximize();

  @override
  void onWindowUnmaximize() => unMaximize();

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }
}

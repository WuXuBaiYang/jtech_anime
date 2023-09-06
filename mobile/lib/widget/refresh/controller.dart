import 'package:easy_refresh/easy_refresh.dart';
import 'package:jtech_anime/common/notifier.dart';

/*
* 自定义刷新组件控制器
* @author wuxubaiyang
* @Time 2023/7/15 14:02
*/
class CustomRefreshController extends ValueChangeNotifier<double> {
  // 控制器
  final controller = EasyRefreshController(
      controlFinishRefresh: true, controlFinishLoad: true);

  CustomRefreshController() : super(0);

  // 启动下拉刷新
  void startRefresh() => controller.callRefresh();

  // 停止下拉刷新
  void finishRefresh() => controller.finishRefresh();

  // 停止上拉加载
  void finishLoad() => controller.finishLoad();

  // 停止全部动作
  void finish() {
    finishRefresh();
    finishLoad();
  }
}

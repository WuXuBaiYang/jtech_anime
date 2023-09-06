import 'package:easy_refresh/easy_refresh.dart';
import 'package:jtech_anime_base/common/notifier.dart';

/*
* 自定义刷新组件控制器
* @author wuxubaiyang
* @Time 2023/7/15 14:02
*/
class CustomRefreshController extends ValueChangeNotifier<double> {
  // 控制器
  final controller = EasyRefreshController();

  CustomRefreshController() : super(0);

  // 启动下拉刷新
  void startRefresh() => controller.callRefresh();
}

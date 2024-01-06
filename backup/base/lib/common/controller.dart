import 'notifier.dart';

/*
* 控制器基类
* @author wuxubaiyang
* @Time 2022/3/30 17:32
*/
abstract class BaseController<V> extends ValueChangeNotifier<V> {
  BaseController(super.v);
}

/*
* 控制器基类-表单
* @author wuxubaiyang
* @Time 2022/3/31 15:36
*/
abstract class BaseControllerMap<K, V> extends MapValueChangeNotifier<K, V> {
  BaseControllerMap(super.v);
}

/*
* 控制器基类-集合
* @author wuxubaiyang
* @Time 2022/3/31 15:37
*/
abstract class BaseControllerList<V> extends ListValueChangeNotifier<V> {
  BaseControllerList(super.v);
}

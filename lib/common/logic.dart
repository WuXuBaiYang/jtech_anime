import 'package:flutter/widgets.dart';

/*
* 逻辑处理基类
* @author wuxubaiyang
* @Time 2022/10/20 10:03
*/
abstract class BaseLogic {
  @mustCallSuper
  void init() {}

  void setupArguments(BuildContext context, Map arguments) {}

  void dispose() {}
}

/*
* 带有逻辑管理结构的状态基类
* @author wuxubaiyang
* @Time 2022/11/2 11:19
*/
abstract class LogicState<T extends StatefulWidget, C extends BaseLogic>
    extends State<T> {
  // 初始化逻辑管理
  C initLogic();

  // 缓存逻辑管理对象
  C? _cacheLogic;

  // 获取逻辑对象
  C get logic => _cacheLogic ??= initLogic();

  // 路由参数获取频次
  bool _argumentsOnce = true;

  @override
  void initState() {
    super.initState();
    logic.init();
  }

  @override
  Widget build(BuildContext context) {
    if (_argumentsOnce) {
      final arguments = ModalRoute.of(context)?.settings.arguments as Map?;
      if (arguments != null && arguments.isNotEmpty) {
        logic.setupArguments(context, arguments);
        _argumentsOnce = false;
      }
    }
    return buildWidget(context);
  }

  Widget buildWidget(BuildContext context);

  @override
  void dispose() {
    logic.dispose();
    super.dispose();
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/*
* 带缓存的future构造器
* @author wuxubaiyang
* @Time 2022-07-27 09:04:01
*/
class CacheFutureBuilder<T> extends StatefulWidget {
  // 初始化参数
  final T? initialData;

  // future
  final Future<T> Function() future;

  // 构造器
  final AsyncWidgetBuilder<T> builder;

  // 控制器
  final CacheFutureBuilderController<T>? controller;

  const CacheFutureBuilder({
    Key? key,
    this.controller,
    this.initialData,
    required this.future,
    required this.builder,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CacheFutureBuilderState<T>();
}

/*
* 带缓存的future构造器-状态
* @author wuxubaiyang
* @Time 2022-07-27 09:04:31
*/
class _CacheFutureBuilderState<T> extends State<CacheFutureBuilder<T>> {
  // 控制器管理
  late CacheFutureBuilderController<T> controller =
      widget.controller ?? CacheFutureBuilderController<T>();

  @override
  void initState() {
    super.initState();
    // 监听值变化
    controller.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: controller.futureProxy(widget.future),
      builder: widget.builder,
      initialData: widget.initialData,
    );
  }
}

/*
* 缓存future builder控制器
* @author wuxubaiyang
* @Time 2022-07-27 09:21:29
*/
class CacheFutureBuilderController<V> extends ChangeNotifier
    implements ValueListenable<V?> {
  // 参数数据
  V? _value;

  // 是否缓存
  final bool cached;

  CacheFutureBuilderController({this.cached = true});

  @override
  V? get value => _value;

  // future代理方法
  Future<V> futureProxy(Future<V> Function() future) async {
    if ((cached && null == _value) || !cached) {
      _value = await future();
    }
    return Future.value(_value);
  }

  // 刷新值
  void refreshValue() {
    _value = null;
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'package:jtech_anime_base/common/manage.dart';

/*
* 路由管理类
* @author wuxubaiyang
* @Time 2022/3/17 14:19
*/
class RouterManage extends BaseManage {
  static final RouterManage _instance = RouterManage._internal();

  factory RouterManage() => _instance;

  // 全局路由key
  final GlobalKey<NavigatorState> navigateKey;

  RouteTransitionsBuilder? _transitionsBuilder;

  RouterManage._internal()
      : navigateKey = GlobalKey(debugLabel: 'RouterNavigateKey');

  // 获取路由对象
  NavigatorState? get navigator => navigateKey.currentState;

  // 设置基础参数
  Future<void> setup({
    RouteTransitionsBuilder? transitionsBuilder,
  }) async {
    _transitionsBuilder = transitionsBuilder;
  }

  // 获取页面参数
  V? find<V>(BuildContext context, String key) {
    dynamic temp = ModalRoute.of(context)?.settings.arguments;
    if (temp is Map) {
      temp = temp[key];
    }
    return temp != null ? temp as V : temp;
  }

  // 页面跳转
  Future<T?>? push<T>({
    required RoutePageBuilder builder,
    String? name,
    Object? arguments,
    bool? opaque,
    Color? barrierColor,
    bool? barrierDismissible,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
    RouteTransitionsBuilder? transitionsBuilder,
    bool fullscreenDialog = false,
  }) {
    return navigator?.push<T>(_createPageRoute<T>(
      builder: builder,
      name: name,
      arguments: arguments,
      opaque: opaque,
      barrierColor: barrierColor,
      barrierDismissible: barrierDismissible,
      transitionDuration: transitionDuration,
      reverseTransitionDuration: reverseTransitionDuration,
      transitionsBuilder: transitionsBuilder,
      fullscreenDialog: fullscreenDialog,
    ));
  }

  // 根据url进行页面跳转，参数以queryParams方式传递
  Future<T?>? pushUrl<T>(String url) {
    final uri = Uri.parse(url);
    return navigator?.pushNamed<T>(
      uri.path,
      arguments: uri.queryParameters,
    );
  }

  // 页面跳转
  Future<T?>? pushNamed<T>(String path, {Object? arguments}) {
    return navigator?.pushNamed<T>(
      path,
      arguments: arguments,
    );
  }

  // 页面跳转并移除到目标页面
  Future<T?>? pushAndRemoveUntil<T>({
    required RoutePageBuilder builder,
    required untilPath,
    String? name,
    Object? arguments,
    bool? opaque,
    Color? barrierColor,
    bool? barrierDismissible,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
    RouteTransitionsBuilder? transitionsBuilder,
    bool fullscreenDialog = false,
  }) {
    return navigator?.pushAndRemoveUntil<T>(
      _createPageRoute<T>(
        builder: builder,
        name: name,
        arguments: arguments,
        opaque: opaque,
        barrierColor: barrierColor,
        barrierDismissible: barrierDismissible,
        transitionDuration: transitionDuration,
        reverseTransitionDuration: reverseTransitionDuration,
        transitionsBuilder: transitionsBuilder,
        fullscreenDialog: fullscreenDialog,
      ),
      ModalRoute.withName(untilPath),
    );
  }

  // 跳转页面并一直退出到目标页面
  Future<T?>? pushNamedAndRemoveUntil<T>(String path,
      {required String untilPath, Object? arguments}) {
    return navigator?.pushNamedAndRemoveUntil<T>(
      path,
      ModalRoute.withName(untilPath),
      arguments: arguments,
    );
  }

  // 跳转页面并一直退出到目标页面
  Future<T?>? pushReplacement<T, TO>({
    required RoutePageBuilder builder,
    String? name,
    Object? arguments,
    bool? opaque,
    Color? barrierColor,
    bool? barrierDismissible,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
    RouteTransitionsBuilder? transitionsBuilder,
    bool fullscreenDialog = false,
  }) {
    return navigator?.pushReplacement<T, TO>(_createPageRoute<T>(
      builder: builder,
      name: name,
      arguments: arguments,
      opaque: opaque,
      barrierColor: barrierColor,
      barrierDismissible: barrierDismissible,
      transitionDuration: transitionDuration,
      reverseTransitionDuration: reverseTransitionDuration,
      transitionsBuilder: transitionsBuilder,
      fullscreenDialog: fullscreenDialog,
    ));
  }

  // 跳转并替换当前页面
  Future<T?>? pushReplacementNamed<T, TO>(String path,
      {TO? result, Object? arguments}) {
    return navigator?.pushReplacementNamed<T, TO>(
      path,
      result: result,
      arguments: arguments,
    );
  }

  // 退出当前页面并跳转目标页面
  Future<T?>? popAndPushNamed<T, TO>(String path,
      {TO? result, Object? arguments}) {
    return navigator?.popAndPushNamed<T, TO>(
      path,
      result: result,
      arguments: arguments,
    );
  }

  // 创建Material风格的页面路由对象
  PageRouteBuilder<T> _createPageRoute<T>({
    required RoutePageBuilder builder,
    String? name,
    Object? arguments,
    bool? opaque,
    Color? barrierColor,
    bool? barrierDismissible,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
    RouteTransitionsBuilder? transitionsBuilder,
    bool fullscreenDialog = false,
  }) {
    // 默认值
    transitionsBuilder ??= _transitionsBuilder ?? _defTransitionsBuilderWidget;
    transitionDuration ??= const Duration(milliseconds: 350);
    reverseTransitionDuration ??= const Duration(milliseconds: 350);
    opaque ??= true;
    barrierDismissible ??= false;
    return PageRouteBuilder<T>(
      pageBuilder: builder,
      transitionsBuilder: transitionsBuilder,
      transitionDuration: transitionDuration,
      reverseTransitionDuration: reverseTransitionDuration,
      opaque: opaque,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      fullscreenDialog: fullscreenDialog,
      settings: RouteSettings(
        name: name,
        arguments: arguments,
      ),
    );
  }

  // 默认页面过渡动画
  Widget _defTransitionsBuilderWidget(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(0, 1);
    const end = Offset.zero;
    const curve = Curves.ease;
    final tween = Tween(
      begin: begin,
      end: end,
    ).chain(CurveTween(curve: curve));
    return SlideTransition(
      position: animation.drive(tween),
      child: child,
    );
  }

  // 页面退出
  Future<bool>? maybePop<T>([T? result]) => navigator?.maybePop<T>(result);

  // 页面退出
  void pop<T>([T? result]) => navigator?.pop<T>(result);

  // 判断页面是否可退出
  bool? canPop() => navigator?.canPop();

  // 页面连续退出
  void popUntil({required String untilPath}) =>
      navigator?.popUntil(ModalRoute.withName(untilPath));

  // 处理路由动画
  RouteFactory onGenerateRoute({
    required Map<String, WidgetBuilder> routesMap,
    WidgetBuilder? errorPage,
    String? name,
    bool? opaque,
    Color? barrierColor,
    bool? barrierDismissible,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
    RouteTransitionsBuilder? transitionsBuilder,
    bool fullscreenDialog = false,
  }) {
    return (settings) {
      return _createPageRoute(
        builder: (c, anim, secAnim) {
          final name = settings.name;
          if (name != null && name.isNotEmpty) {
            final fun = routesMap[name];
            if (fun != null) return fun(c);
          }
          return errorPage?.call(c) ?? const SizedBox();
        },
        name: name,
        opaque: opaque,
        barrierColor: barrierColor,
        arguments: settings.arguments,
        barrierDismissible: barrierDismissible,
        transitionDuration: transitionDuration,
        reverseTransitionDuration: reverseTransitionDuration,
        transitionsBuilder: transitionsBuilder,
        fullscreenDialog: fullscreenDialog,
      );
    };
  }
}

// 单例调用
final router = RouterManage();

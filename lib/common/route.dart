import 'package:go_router/go_router.dart';
import 'package:jtech_anime/page/splash/index.dart';

/*
* 路由路径静态变量
* @author wuxubaiyang
* @Time 2022/9/8 14:55
*/
class RoutePath {
  // 路由表
  static final routers = GoRouter(routes: [
    // 启动页
    GoRoute(path: '/', builder: (_, __) => const SplashPage()),
  ]);
}

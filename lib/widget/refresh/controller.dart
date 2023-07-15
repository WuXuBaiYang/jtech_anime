import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:jtech_anime/common/notifier.dart';
import 'package:flutter/material.dart';

/*
* 自定义刷新组件控制器
* @author wuxubaiyang
* @Time 2023/7/15 14:02
*/
class CustomRefreshController extends ValueChangeNotifier<double> {
  // 刷新控制key
  final refreshKey = GlobalKey<RefreshIndicatorState>();

  // 加载更多控制key
  final loadKey = GlobalKey<CustomRefreshIndicatorState>();

  CustomRefreshController() : super(0);

  // 启动下拉刷新
  void startRefresh() => refreshKey.currentState?.show();
}

import 'package:flutter/material.dart';

/*
* 加载视图
* @author wuxubaiyang
* @Time 2023/11/21 16:23
*/
class LoadingView extends StatelessWidget {
  // 是否加载中
  final bool loading;

  // 子元素构造器
  final WidgetBuilder builder;

  // 自定义加载中视图
  final Widget? loadingView;

  const LoadingView({
    super.key,
    required this.loading,
    required this.builder,
    this.loadingView,
  });

  @override
  Widget build(BuildContext context) {
    return loading ? _buildLoadingView() : builder(context);
  }

  // 构建加载中视图
  Widget _buildLoadingView() {
    return Center(
      child: loadingView ?? const CircularProgressIndicator(),
    );
  }
}

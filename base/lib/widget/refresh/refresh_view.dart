import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';

import 'controller.dart';

// 异步刷新回调
typedef AsyncRefreshCallback = Future<void> Function(bool loadMore);

/*
* 自定义刷新组件
* @author wuxubaiyang
* @Time 2023/7/14 9:13
*/
class CustomRefreshView extends StatefulWidget {
  // 子元素
  final Widget child;

  // 是否启用下拉刷新
  final bool enableRefresh;

  // 是否启用上拉加载
  final bool enableLoadMore;

  // 异步加载回调
  final AsyncRefreshCallback onRefresh;

  // 是否初始化加载更多
  final bool initialRefresh;

  // 下拉刷新的触发距离
  final double refreshTriggerOffset;

  // 加载更多的触发距离
  final double loadMoreTriggerOffset;

  // 刷新组件控制器
  final CustomRefreshController controller;

  // 头部枚举
  final CustomRefreshViewHeader header;

  // 足部枚举
  final CustomRefreshViewFooter footer;

  CustomRefreshView({
    super.key,
    required this.child,
    required this.onRefresh,
    this.enableRefresh = true,
    this.enableLoadMore = false,
    this.initialRefresh = false,
    this.refreshTriggerOffset = 80,
    this.loadMoreTriggerOffset = 80,
    CustomRefreshController? controller,
    this.header = CustomRefreshViewHeader.bezier,
    this.footer = CustomRefreshViewFooter.classic,
  }) : controller = controller ?? CustomRefreshController();

  @override
  State<StatefulWidget> createState() => _CustomRefreshViewState();
}

/*
* 自定义刷新组件-状态
* @author wuxubaiyang
* @Time 2023/7/14 9:15
*/
class _CustomRefreshViewState extends State<CustomRefreshView>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final onRefresh =
        widget.enableRefresh ? () => widget.onRefresh(false) : null;
    final onloadMore =
        widget.enableLoadMore ? () => widget.onRefresh(true) : null;
    return EasyRefresh(
      onLoad: onloadMore,
      onRefresh: onRefresh,
      triggerAxis: Axis.vertical,
      refreshOnStart: widget.initialRefresh,
      footer: widget.footer.getFooter(
        triggerOffset: widget.loadMoreTriggerOffset,
      ),
      header: widget.header.getHeader(
        triggerOffset: widget.refreshTriggerOffset,
      ),
      controller: widget.controller.controller,
      child: widget.child,
    );
  }
}

// 自定义刷新组件头部枚举
enum CustomRefreshViewHeader { classic, bezier }

// 自定义刷新组件头部枚举扩展
extension _CustomRefreshViewHeaderExtension on CustomRefreshViewHeader {
  // 获取刷新组件头部
  Header getHeader({double triggerOffset = 100}) {
    switch (this) {
      case CustomRefreshViewHeader.classic:
        return ClassicHeader(
          triggerOffset: triggerOffset,
          dragText: '下拉刷新',
          armedText: '释放刷新',
          readyText: '准备刷新',
          processingText: '正在刷新',
          processedText: '刷新完成',
          noMoreText: '没有更多了',
          failedText: '刷新失败',
          messageText: '上次更新：%T',
        );
      case CustomRefreshViewHeader.bezier:
        return BezierCircleHeader(
          triggerOffset: triggerOffset,
        );
    }
  }
}

// 自定义刷新组件足部枚举
enum CustomRefreshViewFooter { classic, bezier }

// 自定义刷新组件足部枚举扩展
extension _CustomRefreshViewFooterExtension on CustomRefreshViewFooter {
  // 获取刷新组件足部
  Footer getFooter({double triggerOffset = 100}) {
    switch (this) {
      case CustomRefreshViewFooter.classic:
        return ClassicFooter(
          triggerOffset: triggerOffset,
          dragText: '上拉加载',
          armedText: '释放加载',
          readyText: '准备加载',
          processingText: '正在加载',
          processedText: '加载完成',
          noMoreText: '没有更多了',
          failedText: '加载失败',
          messageText: '上次更新：%T',
        );
      case CustomRefreshViewFooter.bezier:
        return BezierFooter(
          triggerOffset: triggerOffset,
        );
    }
  }
}

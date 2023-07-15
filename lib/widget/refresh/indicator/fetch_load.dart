import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jtech_anime/manage/theme.dart';
import 'package:jtech_anime/widget/status_box.dart';

/*
* 加载更多指示器
* @author wuxubaiyang
* @Time 2023/7/15 12:54
*/
class FetchLoadIndicator extends StatefulWidget {
  // key
  final Key? indicatorKey;

  // 子元素
  final Widget child;

  // 异步回调
  final AsyncCallback onLoad;

  // 加载更多指示器高度
  final double loadHeight;

  // 指示器触发距离
  final double indicatorSize;

  // 控制器
  final IndicatorController? controller;

  const FetchLoadIndicator({
    super.key,
    this.indicatorKey,
    required this.child,
    required this.onLoad,
    this.controller,
    this.loadHeight = 150,
    this.indicatorSize = 150,
  });

  @override
  State<StatefulWidget> createState() => _FetchLoadIndicatorState();
}

/*
* 加载更多指示器-状态
* @author wuxubaiyang
* @Time 2023/7/15 12:57
*/
class _FetchLoadIndicatorState extends State<FetchLoadIndicator> {
  @override
  Widget build(BuildContext context) {
    return CustomRefreshIndicator(
      autoRebuild: false,
      key: widget.indicatorKey,
      onRefresh: widget.onLoad,
      controller: widget.controller,
      offsetToArmed: widget.indicatorSize,
      leadingScrollIndicatorVisible: false,
      trailingScrollIndicatorVisible: true,
      trigger: IndicatorTrigger.trailingEdge,
      triggerMode: IndicatorTriggerMode.onEdge,
      builder: _buildLoadMoreAnime,
      child: widget.child,
    );
  }

  // 构建加载更多动画
  Widget _buildLoadMoreAnime(
      BuildContext context, Widget child, IndicatorController controller) {
    final height = widget.loadHeight;
    final appContentColor = kPrimaryColor;
    return AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final dy =
              controller.value.clamp(0.0, 1.25) * -(height - (height * 0.25));
          return Stack(
            children: [
              Transform.translate(
                offset: Offset(0.0, dy),
                child: child,
              ),
              Positioned(
                left: 0,
                right: 0,
                height: height,
                bottom: -height,
                child: Container(
                  alignment: Alignment.center,
                  constraints: const BoxConstraints.expand(),
                  transform: Matrix4.translationValues(0.0, dy, 0.0),
                  child: Column(
                    children: [
                      if (controller.isLoading)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8, top: 18),
                          child: StatusBox(
                              status: StatusBoxStatus.loading, animSize: 14),
                        )
                      else
                        Icon(Icons.keyboard_arrow_up, color: appContentColor),
                      Text(
                        controller.isLoading ? "正在加载~~" : "上拉加载更多",
                        style: TextStyle(color: appContentColor),
                      )
                    ],
                  ),
                ),
              ),
            ],
          );
        });
  }
}

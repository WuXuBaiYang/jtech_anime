import 'package:flutter/material.dart';

/*
* 保持页面状态的组件，用于解决页面切换时重绘的问题
* @author wuxubaiyang
* @Time 2023/9/8 16:53
*/
class KeepAliveWrapper extends StatefulWidget {
  const KeepAliveWrapper({
    super.key,
    this.keepAlive = true,
    required this.child,
  });

  final bool keepAlive;
  final Widget child;

  @override
  State<StatefulWidget> createState() => _KeepAliveWrapperState();
}

/*
* 保持页面状态的组件-状态，用于解决页面切换时重绘的问题
* @author wuxubaiyang
* @Time 2023/9/8 16:53
*/
class _KeepAliveWrapperState extends State<KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  void didUpdateWidget(covariant KeepAliveWrapper oldWidget) {
    if (oldWidget.keepAlive != widget.keepAlive) {
      updateKeepAlive();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  bool get wantKeepAlive => widget.keepAlive;
}

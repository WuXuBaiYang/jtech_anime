import 'package:flutter/material.dart';

/*
* 忽略区域内的所有手势
* @author wuxubaiyang
* @Time 2023/11/10 8:46
*/
class IgnoreGesture extends StatelessWidget {
  // 子组件
  final Widget child;

  const IgnoreGesture({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      // 点击事件
      onTap: () {},
      onTapUp: (_) {},
      onTapDown: (_) {},
      onTapCancel: () {},
      // 长按事件
      onLongPress: () {},
      onLongPressUp: () {},
      onLongPressDown: (_) {},
      onLongPressStart: (_) {},
      onLongPressEnd: (_) {},
      onLongPressMoveUpdate: (_) {},
      onLongPressCancel: () {},
      // 双击事件
      onDoubleTap: () {},
      onDoubleTapDown: (_) {},
      onDoubleTapCancel: () {},
      // 次要点击事件
      onSecondaryTap: () {},
      onSecondaryTapUp: (_) {},
      onSecondaryTapDown: (_) {},
      onSecondaryTapCancel: () {},
      // 次要长按事件
      onSecondaryLongPress: () {},
      onSecondaryLongPressUp: () {},
      onSecondaryLongPressDown: (_) {},
      onSecondaryLongPressStart: (_) {},
      onSecondaryLongPressEnd: (_) {},
      onSecondaryLongPressMoveUpdate: (_) {},
      onSecondaryLongPressCancel: () {},
      // 三击事件
      onTertiaryTapUp: (_) {},
      onTertiaryTapDown: (_) {},
      onTertiaryTapCancel: () {},
      // 三击长按事件
      onTertiaryLongPress: () {},
      onTertiaryLongPressUp: () {},
      onTertiaryLongPressDown: (_) {},
      onTertiaryLongPressStart: (_) {},
      onTertiaryLongPressEnd: (_) {},
      onTertiaryLongPressMoveUpdate: (_) {},
      onTertiaryLongPressCancel: () {},
      // 按压事件
      onForcePressStart: (_) {},
      onForcePressEnd: (_) {},
      onForcePressPeak: (_) {},
      onForcePressUpdate: (_) {},
      // 垂直拖动事件
      onVerticalDragDown: (_) {},
      onVerticalDragStart: (_) {},
      onVerticalDragEnd: (_) {},
      onVerticalDragUpdate: (_) {},
      onVerticalDragCancel: () {},
      // 水平拖动事件
      onHorizontalDragDown: (_) {},
      onHorizontalDragStart: (_) {},
      onHorizontalDragEnd: (_) {},
      onHorizontalDragUpdate: (_) {},
      onHorizontalDragCancel: () {},
      child: child,
    );
  }
}

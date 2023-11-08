import 'dart:math';
import 'package:flutter/material.dart';

/*
* 垂直进度组件
* @author wuxubaiyang
* @Time 2023/11/6 15:52
*/
class VerticalProgressView extends StatelessWidget {
  // 形状
  final ShapeBorder? shape;

  // 外间距
  final EdgeInsetsGeometry? margin;

  // 进度条尺寸
  final Size? size;

  // 图标
  final Widget? icon;

  // 图标内间距
  final EdgeInsetsGeometry? iconPadding;

  // 进度
  final double progress;

  const VerticalProgressView({
    super.key,
    required this.progress,
    this.size,
    this.icon,
    this.shape,
    this.margin,
    this.iconPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 270 * pi / 180,
      child: Card(
        elevation: 0,
        color: Colors.black38,
        clipBehavior: Clip.antiAlias,
        margin: margin ?? const EdgeInsets.all(24),
        shape: shape ??
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            SizedBox.fromSize(
              size: size ?? const Size(160, 40),
              child: LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                value: progress,
              ),
            ),
            Padding(
              padding: iconPadding ?? const EdgeInsets.all(8),
              child: icon ?? const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}

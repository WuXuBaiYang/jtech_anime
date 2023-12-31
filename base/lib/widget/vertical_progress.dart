import 'dart:math';
import 'package:flutter/material.dart';
import 'package:jtech_anime_base/base.dart';

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
        margin: margin,
        color: Colors.black38,
        clipBehavior: Clip.antiAlias,
        shape: shape ??
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            SizedBox.fromSize(
              size: size ?? const Size(160, 35),
              child: LinearProgressIndicator(
                value: range(progress, 0, 1),
                backgroundColor: Colors.transparent,
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

import 'dart:math';
import 'package:flutter/material.dart';

/*
* 半圆形绘制器
* @author wuxubaiyang
* @Time 2023/11/24 15:17
*/
class HalfCirclePainter extends CustomPainter {
  // 传入要绘制的颜色
  final (Color, Color) colors;

  HalfCirclePainter(this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()..color = colors.$1;
    final paint2 = Paint()..color = colors.$2;

    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width / 2,
    );
    canvas.drawArc(rect, 0, pi, true, paint1);
    canvas.drawArc(rect, pi, pi, true, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

import 'package:blur/blur.dart';
import 'package:flutter/material.dart';

/*
* 模糊组件
* @author wuxubaiyang
* @Time 2023/9/6 16:48
*/
class BlurView extends StatelessWidget {
  // 模糊度
  final double blur;

  // 模糊颜色
  final Color color;

  // 元素
  final Widget child;

  const BlurView({
    super.key,
    required this.blur,
    required this.child,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Blur(
      blur: blur,
      blurColor: color,
      child: child,
    );
  }
}

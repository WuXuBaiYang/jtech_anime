import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/*
* lottie动画组件
* @author wuxubaiyang
* @Time 2023/9/6 16:30
*/
class LottieView extends StatelessWidget {
  // 资源路径
  final String assetName;

  // 宽度
  final double? width;

  // 高度
  final double? height;

  // 填充方式
  final BoxFit? fit;

  const LottieView(this.assetName, {
    super.key,
    this.width,
    this.height,
    this.fit,
  });

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      assetName,
      frameRate: FrameRate.max,
      height: height,
      width: width,
      fit: fit,
    );
  }
}

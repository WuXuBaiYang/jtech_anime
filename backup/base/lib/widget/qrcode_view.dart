import 'package:flutter/material.dart';
import 'package:zxing_widget/qrcode.dart';

/*
* 根据输入文本生成二维码
* @author wuxubaiyang
* @Time 2023/9/19 13:38
*/
class QRCodeView extends StatelessWidget {
  // 输入文本
  final String text;

  // 二维码尺寸
  final Size size;

  // 二维码颜色
  final Color color;

  // 背景色
  final Color backgroundColor;

  // 中间要放的元素
  final Widget? child;

  const QRCodeView({
    super.key,
    required this.text,
    this.child,
    this.color = Colors.black,
    this.size = const Size(200, 200),
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return BarcodeWidget(
      QrcodePainter(
        text,
        foregroundColor: color,
        backgroundColor: backgroundColor,
        errorCorrectionLevel: ErrorCorrectionLevel.H,
      ),
      size: size,
      child: child,
    );
  }
}

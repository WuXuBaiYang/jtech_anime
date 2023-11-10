import 'package:flutter/material.dart';

///draw call back
typedef OnDraw = void Function(Canvas canvas, Size size);

///custom clip path
typedef PathBuilder = Path Function(Size size);

class MaskView extends StatelessWidget {
  ///view size
  final Size maskViewSize;

  ///color for background
  final Color backgroundColor;

  ///color for height light
  final Color color;

  /// height-light rect shape
  final RRect? rRect;

  /// custom height-light shape
  final PathBuilder? pathBuilder;

  ///draw more things
  final OnDraw? drawAfter;

  const MaskView({
    Key? key,
    required this.maskViewSize,
    required this.backgroundColor,
    required this.color,
    this.rRect,
    this.pathBuilder,
    this.drawAfter,
  })  : assert(rRect != null || pathBuilder != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: maskViewSize,
        isComplex: true,
        painter: _MaskPainter(this),
      ),
    );
  }
}

class _MaskPainter extends CustomPainter {
  ///config
  final MaskView config;

  final Paint heightLightPaint;

  final Paint layerPaint;

  _MaskPainter(this.config)
      : heightLightPaint = Paint()
          ..isAntiAlias = true
          ..blendMode = BlendMode.srcIn
          ..color = config.color
          ..style = PaintingStyle.fill,
        layerPaint = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Offset.zero & size, layerPaint);
    canvas.drawColor(config.backgroundColor, BlendMode.src);
    if (config.pathBuilder != null) {
      Path path = config.pathBuilder!(size);
      canvas.drawPath(path, heightLightPaint);
    } else {
      canvas.drawRRect(config.rRect!, heightLightPaint);
    }
    canvas.restore();
    //draw custom things
    config.drawAfter?.call(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

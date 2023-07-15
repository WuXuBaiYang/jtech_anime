import 'dart:math';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/semantics.dart';

// 类型转换
T? _ambiguity<T>(T? value) => value;

// 星星颜色获取回调
typedef StarColorGetter = Color Function(int index);

/*
* 动漫效果的下拉刷新指示器
* @author wuxubaiyang
* @Time 2023/7/15 12:33
*/
class WarpRefreshIndicator extends StatefulWidget {
  // key
  final Key? indicatorKey;

  // 子元素
  final Widget child;

  // 异步回调
  final AsyncCallback onRefresh;

  // 星星数量
  final int starsCount;

  // 背景色
  final Color background;

  // 星星颜色
  final Color skyColor;

  // 控制器
  final IndicatorController? controller;

  //获取星星颜色回调
  final StarColorGetter starColorGetter;

  // 指示器触发距离
  final double indicatorSize;

  const WarpRefreshIndicator({
    super.key,
    this.indicatorKey,
    required this.child,
    required this.onRefresh,
    this.controller,
    this.starsCount = 30,
    this.indicatorSize = 150,
    this.skyColor = Colors.black,
    this.background = Colors.white,
    this.starColorGetter = _defaultStarColorGetter,
  });

  static Color _defaultStarColorGetter(int index) =>
      HSLColor.fromAHSL(1, Random().nextDouble() * 360, 1, 0.98).toColor();

  @override
  State<StatefulWidget> createState() => _WarpRefreshIndicatorState();
}

/*
* 动漫效果下拉刷新指示器
* @author wuxubaiyang
* @Time 2023/7/15 12:34
*/
class _WarpRefreshIndicatorState extends State<WarpRefreshIndicator>
    with SingleTickerProviderStateMixin {
  // 指示器状态
  WarpAnimationState state = WarpAnimationState.stopped;
  final random = Random();

  // 星星存储集合
  List<Star> stars = [];
  final offsetTween = Tween<Offset>(begin: Offset.zero, end: Offset.zero);
  final angleTween = Tween<double>(begin: 0, end: 0);
  final scaleTween = Tween(begin: 1.0, end: 0.75);
  final radiusTween = Tween(begin: 0.0, end: 16.0);
  late AnimationController shakeController;

  @override
  void initState() {
    super.initState();
    // 初始化晃动动画控制器
    shakeController = AnimationController(
        duration: const Duration(milliseconds: 100), vsync: this);
  }

  Offset _getRandomOffset() =>
      Offset(random.nextInt(10) - 5, random.nextInt(10) - 5);

  double _getRandomAngle() {
    final degrees = ((random.nextDouble() * 2) - 1);
    final radians = degrees == 0 ? 0.0 : degrees / 360.0;
    return radians;
  }

  void _shiftAndGenerateRandomShakeTransform() {
    offsetTween.begin = offsetTween.end;
    offsetTween.end = _getRandomOffset();
    angleTween.begin = angleTween.end;
    angleTween.end = _getRandomAngle();
  }

  void _startShakeAnimation() {
    _shiftAndGenerateRandomShakeTransform();
    shakeController.animateTo(1.0);
    state = WarpAnimationState.playing;
    stars = List.generate(widget.starsCount,
        (i) => Star(initialColor: widget.starColorGetter(i)));
  }

  void _resetShakeAnimation() {
    _shiftAndGenerateRandomShakeTransform();
    shakeController.value = 0.0;
    shakeController.animateTo(1.0);
  }

  void _stopShakeAnimation() {
    offsetTween.end = Offset.zero;
    angleTween.end = 0.0;
    state = WarpAnimationState.stopped;
    _shiftAndGenerateRandomShakeTransform();
    shakeController.stop();
    shakeController.value = 0.0;
    stars = [];
  }

  @override
  Widget build(BuildContext context) {
    return CustomRefreshIndicator(
      autoRebuild: false,
      key: widget.indicatorKey,
      onRefresh: widget.onRefresh,
      controller: widget.controller,
      offsetToArmed: widget.indicatorSize,
      leadingScrollIndicatorVisible: true,
      trailingScrollIndicatorVisible: false,
      trigger: IndicatorTrigger.leadingEdge,
      triggerMode: IndicatorTriggerMode.onEdge,
      onStateChanged: (change) {
        if (change.didChange(to: IndicatorState.loading)) {
          _startShakeAnimation();
        } else if (change.didChange(to: IndicatorState.finalizing)) {
          _stopShakeAnimation();
        }
      },
      builder: _buildRefreshAnime,
      child: Container(
        color: widget.background,
        child: widget.child,
      ),
    );
  }

  // 构建刷新动画
  Widget _buildRefreshAnime(
      BuildContext context, Widget child, IndicatorController controller) {
    final animation = Listenable.merge([controller, shakeController]);
    return Stack(
      children: <Widget>[
        AnimatedBuilder(
          animation: shakeController,
          builder: (_, __) => LayoutBuilder(
            builder: (_, __) => CustomPaint(
              painter: Sky(stars: stars, color: widget.skyColor),
              child: const SizedBox.expand(),
            ),
          ),
        ),
        AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            return Transform.scale(
              scale: scaleTween.transform(controller.value),
              child: Builder(builder: (context) {
                if (shakeController.value == 1.0 &&
                    state == WarpAnimationState.playing) {
                  _ambiguity(SchedulerBinding.instance)!
                      .addPostFrameCallback((_) => _resetShakeAnimation());
                }
                return Transform.rotate(
                  angle: angleTween.transform(shakeController.value),
                  child: Transform.translate(
                    offset: offsetTween.transform(shakeController.value),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        radiusTween.transform(controller.value),
                      ),
                      child: child,
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    shakeController.dispose();
    super.dispose();
  }
}

// 刷新动画状态
enum WarpAnimationState { stopped, playing }

// 星星对象
class Star {
  Offset? position;
  Color? color;
  double value;
  late Offset speed;
  final Color initialColor;
  late double angle;

  Star({
    required this.initialColor,
  }) : value = 0.0;

  static const _minOpacity = 0.1;
  static const _maxOpacity = 1.0;

  void _init(Rect rect) {
    position = rect.center;
    value = 0.0;
    final random = Random();
    angle = random.nextDouble() * pi * 3;
    speed = Offset(cos(angle), sin(angle));
    const minSpeedScale = 20;
    const maxSpeedScale = 35;
    final speedScale = minSpeedScale +
        random.nextInt(maxSpeedScale - minSpeedScale).toDouble();
    speed = speed.scale(
      speedScale,
      speedScale,
    );
    final t = speedScale / maxSpeedScale;
    final opacity = _minOpacity + (_maxOpacity - _minOpacity) * t;
    color = initialColor.withOpacity(opacity);
  }

  draw(Canvas canvas, Rect rect) {
    if (position == null) {
      _init(rect);
    }

    value++;
    final startPosition = Offset(position!.dx, position!.dy);
    final endPosition = position! + (speed * (value * 0.3));
    position = speed + position!;
    final paint = Paint()..color = color!;

    final startShiftAngle = angle + (pi / 2);
    final startShift = Offset(cos(startShiftAngle), sin(startShiftAngle));
    final shiftedStartPosition =
        startPosition + (startShift * (0.75 + value * 0.01));

    final endShiftAngle = angle + (pi / 2);
    final endShift = Offset(cos(endShiftAngle), sin(endShiftAngle));
    final shiftedEndPosition = endPosition + (endShift * (1.5 + value * 0.01));

    final path = Path()
      ..moveTo(startPosition.dx, startPosition.dy)
      ..lineTo(startPosition.dx, startPosition.dy)
      ..lineTo(shiftedStartPosition.dx, shiftedStartPosition.dy)
      ..lineTo(shiftedEndPosition.dx, shiftedEndPosition.dy)
      ..lineTo(endPosition.dx, endPosition.dy);

    if (!rect.contains(startPosition)) {
      _init(rect);
    }

    canvas.drawPath(path, paint);
  }
}

// 天空对象
class Sky extends CustomPainter {
  final List<Star> stars;
  final Color color;

  Sky({
    required this.stars,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var rect = Offset.zero & size;

    canvas.drawRect(rect, Paint()..color = color);

    for (final star in stars) {
      star.draw(canvas, rect);
    }
  }

  @override
  SemanticsBuilderCallback get semanticsBuilder {
    return (Size size) {
      var rect = Offset.zero & size;
      return [
        CustomPainterSemantics(
          rect: rect,
          properties: const SemanticsProperties(
            label: 'Lightspeed animation.',
            textDirection: TextDirection.ltr,
          ),
        ),
      ];
    };
  }

  @override
  bool shouldRepaint(Sky oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(Sky oldDelegate) => false;
}

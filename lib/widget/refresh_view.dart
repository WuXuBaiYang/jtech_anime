import 'dart:math';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/semantics.dart';
import 'package:jtech_anime/manage/theme.dart';
import 'package:jtech_anime/widget/status_box.dart';

// 类型转换
T? _ambiguity<T>(T? value) => value;

// 刷新动画状态
enum WarpAnimationState {
  stopped,
  playing,
}

// 异步刷新回调
typedef AsyncRefreshCallback = Future<void> Function(bool loadMore);

// 星星颜色获取回调
typedef StarColorGetter = Color Function(int index);

/*
* 自定义刷新组件
* @author wuxubaiyang
* @Time 2023/7/14 9:13
*/
class CustomRefreshView extends StatefulWidget {
  // 子元素
  final Widget child;

  // 是否启用下拉刷新
  final bool enableRefresh;

  // 是否启用上拉加载
  final bool enableLoadMore;

  // 异步加载回调
  final AsyncRefreshCallback onRefresh;

  // 加载更多视图高度
  final double loadMoreHeight;

  // 星星数量
  final int starsCount;

  // 子元素背景色
  final Color childBackground;

  // 星星颜色
  final Color skyColor;

  //获取星星颜色回调
  final StarColorGetter starColorGetter;

  // 是否初始化加载更多
  final bool initialRefresh;

  const CustomRefreshView({
    super.key,
    required this.onRefresh,
    required this.child,
    this.starsCount = 30,
    this.enableRefresh = true,
    this.loadMoreHeight = 150,
    this.initialRefresh = false,
    this.enableLoadMore = false,
    this.skyColor = Colors.black,
    this.childBackground = Colors.white,
    this.starColorGetter = _defaultStarColorGetter,
  });

  static Color _defaultStarColorGetter(int index) =>
      HSLColor.fromAHSL(1, Random().nextDouble() * 360, 1, 0.98).toColor();

  @override
  State<StatefulWidget> createState() => _CustomRefreshViewState();
}

/*
* 自定义刷新组件-状态
* @author wuxubaiyang
* @Time 2023/7/14 9:15
*/
class _CustomRefreshViewState extends State<CustomRefreshView>
    with SingleTickerProviderStateMixin {
  // 指示器key
  final indicatorKey = GlobalKey<CustomRefreshIndicatorState>();

  // 刷新控制器
  final controller = IndicatorController();

  static const _indicatorSize = 150.0;
  final _random = Random();
  WarpAnimationState _state = WarpAnimationState.stopped;

  List<Star> stars = [];
  final _offsetTween = Tween<Offset>(
    begin: Offset.zero,
    end: Offset.zero,
  );
  final _angleTween = Tween<double>(
    begin: 0,
    end: 0,
  );

  late AnimationController shakeController;

  static final _scaleTween = Tween(begin: 1.0, end: 0.75);
  static final _radiusTween = Tween(begin: 0.0, end: 16.0);

  @override
  void initState() {
    shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    super.initState();
    // 初始化加载
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 如果设置了初始化加载，则在第一帧绘制完成之后开始刷新
      if (widget.initialRefresh && widget.enableRefresh) {
        Future.delayed(const Duration(milliseconds: 500))
            .then((value) => indicatorKey.currentState?.refresh());
      }
    });
  }

  Offset _getRandomOffset() => Offset(
        _random.nextInt(10) - 5,
        _random.nextInt(10) - 5,
      );

  double _getRandomAngle() {
    final degrees = ((_random.nextDouble() * 2) - 1);
    final radians = degrees == 0 ? 0.0 : degrees / 360.0;
    return radians;
  }

  void _shiftAndGenerateRandomShakeTransform() {
    _offsetTween.begin = _offsetTween.end;
    _offsetTween.end = _getRandomOffset();

    _angleTween.begin = _angleTween.end;
    _angleTween.end = _getRandomAngle();
  }

  void _startShakeAnimation() {
    _shiftAndGenerateRandomShakeTransform();
    shakeController.animateTo(1.0);
    _state = WarpAnimationState.playing;
    stars = List.generate(
      widget.starsCount,
      (index) => Star(initialColor: widget.starColorGetter(index)),
    );
  }

  void _resetShakeAnimation() {
    _shiftAndGenerateRandomShakeTransform();
    shakeController.value = 0.0;
    shakeController.animateTo(1.0);
  }

  void _stopShakeAnimation() {
    _offsetTween.end = Offset.zero;
    _angleTween.end = 0.0;
    _state = WarpAnimationState.stopped;
    _shiftAndGenerateRandomShakeTransform();
    shakeController.stop();
    shakeController.value = 0.0;
    stars = [];
  }

  // 获取触发条件
  IndicatorTrigger? get trigger {
    if (widget.enableRefresh && widget.enableLoadMore) {
      return IndicatorTrigger.bothEdges;
    }
    if (widget.enableRefresh) return IndicatorTrigger.leadingEdge;
    if (widget.enableLoadMore) return IndicatorTrigger.trailingEdge;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    var child = Container(
      color: widget.childBackground,
      child: widget.child,
    );
    if (trigger == null) return child;
    return CustomRefreshIndicator(
      trigger: trigger!,
      key: indicatorKey,
      autoRebuild: false,
      controller: controller,
      offsetToArmed: _indicatorSize,
      leadingScrollIndicatorVisible: false,
      trailingScrollIndicatorVisible: false,
      triggerMode: IndicatorTriggerMode.onEdge,
      onRefresh: () => widget.onRefresh(controller.edge?.isTrailing ?? false),
      onStateChanged: (change) {
        if (change.didChange(to: IndicatorState.loading)) {
          _startShakeAnimation();
        } else if (change.didChange(to: IndicatorState.finalizing)) {
          _stopShakeAnimation();
        }
      },
      builder: _buildRefreshAnime,
      child: child,
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
              scale: _scaleTween.transform(controller.value),
              child: Builder(builder: (context) {
                if (shakeController.value == 1.0 &&
                    _state == WarpAnimationState.playing) {
                  _ambiguity(SchedulerBinding.instance)!
                      .addPostFrameCallback((_) => _resetShakeAnimation());
                }
                return Transform.rotate(
                  angle: _angleTween.transform(shakeController.value),
                  child: Transform.translate(
                    offset: _offsetTween.transform(shakeController.value),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        _radiusTween.transform(controller.value),
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

  // 构建加载更多动画
  Widget _buildLoadMoreAnime(
      BuildContext context, Widget child, IndicatorController controller) {
    final appContentColor = kPrimaryColor;
    final height = widget.loadMoreHeight;
    return AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final dy =
              controller.value.clamp(0.0, 1.25) * -(height - (height * 0.25));
          return Stack(
            children: [
              Transform.translate(
                offset: Offset(0.0, dy),
                child: child,
              ),
              Positioned(
                bottom: -height,
                left: 0,
                right: 0,
                height: height,
                child: Container(
                  transform: Matrix4.translationValues(0.0, dy, 0.0),
                  padding: const EdgeInsets.only(top: 30.0),
                  constraints: const BoxConstraints.expand(),
                  child: Column(
                    children: [
                      if (controller.isLoading)
                        Container(
                          width: 16,
                          height: 16,
                          margin: const EdgeInsets.only(bottom: 8.0),
                          child: const StatusBox(
                              status: StatusBoxStatus.loading, animSize: 14),
                        )
                      else
                        Icon(Icons.keyboard_arrow_up, color: appContentColor),
                      Text(
                        controller.isLoading ? "正在加载~~" : "上拉加载更多",
                        style: TextStyle(color: appContentColor),
                      )
                    ],
                  ),
                ),
              ),
            ],
          );
        });
  }

  @override
  void dispose() {
    shakeController.dispose();
    super.dispose();
  }
}

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

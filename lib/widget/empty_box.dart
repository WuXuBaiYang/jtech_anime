import 'package:flutter/material.dart';

/*
* 空盒子
* @author wuxubaiyang
* @Time 2023/11/28 15:13
*/
class EmptyBoxView extends StatelessWidget {
  // 子元素
  final Widget? child;

  // 构造器
  final TransitionBuilder? builder;

  // 是否为空
  final bool isEmpty;

  // 提示
  final String hint;

  // 提示字体大小
  final TextStyle? hintStyle;

  // 自定义颜色
  final Color? color;

  // 空图片尺寸
  final double placeholderSize;

  // 动画时长
  final Duration duration;

  // 自定义图标
  final IconData? iconData;

  // 自定义子元素（与iconData互斥）
  final Widget? icon;

  const EmptyBoxView({
    super.key,
    required this.isEmpty,
    this.icon,
    this.child,
    this.color,
    this.builder,
    this.iconData,
    this.hint = '',
    this.hintStyle,
    this.placeholderSize = 100,
    this.duration = const Duration(milliseconds: 150),
  });

  @override
  Widget build(BuildContext context) {
    final crossFadeState =
        isEmpty ? CrossFadeState.showSecond : CrossFadeState.showFirst;
    return AnimatedCrossFade(
      duration: duration,
      crossFadeState: crossFadeState,
      secondChild: _buildPlaceholder(context),
      firstChild: builder?.call(context, child) ?? child ?? const SizedBox(),
      layoutBuilder: (topChild, topChildKey, bottomChild, bottomChildKey) {
        return Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(key: bottomChildKey, child: bottomChild),
            Positioned.fill(key: topChildKey, child: topChild),
          ],
        );
      },
    );
  }

  // 构建空白占位图
  Widget _buildPlaceholder(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleLarge;
    final color = this.color ?? titleStyle?.color?.withOpacity(0.1);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon ??
              Icon(
                color: color,
                size: placeholderSize,
                iconData ?? Icons.inbox,
              ),
          const SizedBox(height: 14),
          Text(hint,
              textAlign: TextAlign.center,
              style: (hintStyle ?? titleStyle)?.copyWith(color: color)),
        ],
      ),
    );
  }
}

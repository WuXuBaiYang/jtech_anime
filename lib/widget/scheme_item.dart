import 'package:flutter/material.dart';
import 'package:jtech_anime/provider/theme.dart';
import 'half_circle.dart';

/*
* 主题配色项
* @author wuxubaiyang
* @Time 2023/11/24 15:36
*/
class ThemeSchemeItem extends StatelessWidget {
  // 主题配色项
  final ThemeSchemeTuple themeScheme;

  // 旋转角度(0-12)
  final double angle;

  // 大小
  final double size;

  // 内间距
  final EdgeInsetsGeometry padding;

  // 点击事件
  final VoidCallback? onPressed;

  // 是否已选中
  final bool isSelected;

  // 自定义tooltip
  final String? tooltip;

  const ThemeSchemeItem({
    super.key,
    required this.themeScheme,
    this.tooltip,
    this.size = 45,
    this.onPressed,
    this.angle = 7,
    this.isSelected = false,
    this.padding = const EdgeInsets.all(4),
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: SizedBox.fromSize(
        size: Size.square(size),
        child: _buildItem(themeScheme),
      ),
    );
  }

  // 构建子项
  Widget _buildItem(ThemeSchemeTuple item) {
    if (isSelected) {
      return IconButton.outlined(
        padding: padding,
        onPressed: onPressed,
        icon: _buildItemSub(item),
        tooltip: tooltip ?? item.label,
      );
    }
    return IconButton(
      padding: padding,
      onPressed: onPressed,
      icon: _buildItemSub(item),
      tooltip: tooltip ?? item.label,
    );
  }

  // 构建子项sub
  Widget _buildItemSub(ThemeSchemeTuple item) {
    return CustomPaint(
      size: Size.infinite,
      painter: HalfCirclePainter((
        item.primary,
        item.secondary,
      )),
    );
  }
}

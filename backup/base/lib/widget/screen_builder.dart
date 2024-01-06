import 'package:flutter/material.dart';
import 'package:jtech_anime_base/manage/config.dart';
import 'package:jtech_anime_base/tool/screen_type.dart';

/*
* 屏幕类型构造器
* @author wuxubaiyang
* @Time 2023/11/14 13:59
*/
class ScreenBuilder extends StatefulWidget {
  // 默认构造器
  final WidgetBuilder builder;

  // 移动端构造器
  final WidgetBuilder? mobile;

  // 平板端构造器
  final WidgetBuilder? pad;

  // 桌面端构造器
  final WidgetBuilder? desktop;

  // 大屏幕融合端构造器
  final WidgetBuilder? fusion;

  const ScreenBuilder({
    super.key,
    required this.builder,
    this.pad,
    this.mobile,
    this.fusion,
    this.desktop,
  });

  @override
  State<StatefulWidget> createState() => _ScreenBuilderState();
}

/*
* 屏幕类型构造器-状态
* @author wuxubaiyang
* @Time 2023/11/14 14:00
*/
class _ScreenBuilderState extends State<ScreenBuilder> {
  // 平台构建对照表
  late final Map<ScreenType, WidgetBuilder?> screenBuilder = {
    ScreenType.pad: widget.pad,
    ScreenType.mobile: widget.mobile,
    ScreenType.fusion: widget.fusion,
    ScreenType.desktop: widget.desktop,
  };

  @override
  Widget build(BuildContext context) {
    final builder = screenBuilder[rootConfig.screenType] ?? widget.builder;
    return builder.call(context);
  }
}

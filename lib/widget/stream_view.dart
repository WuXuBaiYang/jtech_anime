import 'package:flutter/material.dart';
import 'package:jtech_anime/manage/anime_parser/parser.dart';
import 'package:jtech_anime/manage/event.dart';
import 'package:jtech_anime/manage/theme.dart';

/*
* 样式变化监听组件
* @author wuxubaiyang
* @Time 2023/2/14 16:29
*/
class ThemeStreamView extends StatelessWidget {
  final AsyncWidgetBuilder<ThemeEvent> builder;

  const ThemeStreamView({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ThemeEvent>(
      initialData: ThemeEvent(theme.currentTheme),
      stream: event.on<ThemeEvent>(),
      builder: builder,
    );
  }
}

/*
* 解析源变化监听组件
* @author wuxubaiyang
* @Time 2023/2/14 16:29
*/
class SourceStreamView extends StatelessWidget {
  final AsyncWidgetBuilder<SourceChangeEvent> builder;

  const SourceStreamView({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SourceChangeEvent>(
      initialData: SourceChangeEvent(animeParser.currentSource),
      stream: event.on<SourceChangeEvent>(),
      builder: builder,
    );
  }
}

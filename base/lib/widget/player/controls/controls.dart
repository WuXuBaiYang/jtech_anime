import 'package:flutter/material.dart';
import 'package:jtech_anime_base/manage/theme.dart';
import 'package:jtech_anime_base/widget/player/controller.dart';

/*
* 自定义播放器控制层
* @author wuxubaiyang
* @Time 2023/11/6 15:10
*/
abstract class CustomPlayerControls extends StatefulWidget {
  // 控制器
  final CustomVideoPlayerController controller;

  // 自定义样式
  final ThemeData? theme;

  // 标题
  final Widget? title;

  // 顶部leading
  final Widget? leading;

  // 副标题
  final Widget? subTitle;

  // 顶部按钮集合
  final List<Widget> topActions;

  // 底部按钮集合
  final List<Widget> bottomActions;

  // 缓冲状态大小
  final double? buffingSize;

  const CustomPlayerControls({
    super.key,
    required this.controller,
    this.theme,
    this.title,
    this.leading,
    this.subTitle,
    this.buffingSize,
    this.topActions = const [],
    this.bottomActions = const [],
  });

  // 播放器样式
  ThemeData getTheme(BuildContext context) =>
      theme ??
      Theme.of(context).copyWith(
        colorScheme: ColorScheme.dark(
          primary: kPrimaryColor,
          secondary: kSecondaryColor,
          onPrimary: Colors.white,
        ),
        iconButtonTheme: const IconButtonThemeData(
          style: ButtonStyle(
            iconSize: MaterialStatePropertyAll(20),
            iconColor: MaterialStatePropertyAll(Colors.white),
          ),
        ),
        sliderTheme: SliderThemeData(
          trackHeight: 2,
          inactiveTrackColor: Colors.white24,
          thumbShape: const RoundSliderThumbShape(
            enabledThumbRadius: 6,
          ),
          overlayShape: const RoundSliderOverlayShape(
            overlayRadius: 14,
          ),
          secondaryActiveTrackColor: kPrimaryColor.withOpacity(0.3),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
          size: 20,
        ),
      );
}

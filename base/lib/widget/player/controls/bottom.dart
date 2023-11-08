import 'package:flutter/material.dart';
import 'package:jtech_anime_base/base.dart';
import 'package:jtech_anime_base/widget/player/widgets/full_screen_button.dart';
import 'package:jtech_anime_base/widget/player/widgets/mini_screen_button.dart';
import 'package:jtech_anime_base/widget/player/widgets/play_button.dart';
import 'package:jtech_anime_base/widget/player/widgets/play_speed.dart';
import 'package:jtech_anime_base/widget/player/widgets/progress_slider.dart';
import 'package:jtech_anime_base/widget/player/widgets/volume.dart';

/*
* 自定义播放器控制层-底部
* @author wuxubaiyang
* @Time 2023/8/28 10:57
*/
class CustomPlayerControlsBottom extends StatelessWidget {
  // 播放器控制器
  final CustomVideoPlayerController controller;

  // 播放进度控制
  final Stream<Duration?>? seekStream;

  // 扩展组件
  final List<Widget> actions;

  // 是否展示音量按钮
  final bool showVolume;

  // 是否展示倍速按钮
  final bool showSpeed;

  // 是否展示迷你屏幕按钮
  final bool showMiniScreen;

  // 是否展示全屏按钮
  final bool showFullScreen;

  // 是否展示进度条两侧的文本
  final bool showProgressText;

  // 自定义装饰器
  final Decoration? decoration;

  const CustomPlayerControlsBottom({
    super.key,
    required this.controller,
    this.seekStream,
    this.decoration,
    this.showSpeed = true,
    this.showVolume = true,
    this.actions = const [],
    this.showFullScreen = true,
    this.showMiniScreen = true,
    this.showProgressText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: _buildBottomActions(),
    );
  }

  // 构建播放器底部动作条
  Widget _buildBottomActions() {
    return Container(
      decoration: decoration,
      padding: const EdgeInsets.all(14).copyWith(top: 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomPlayerProgressSlider(
            controller: controller,
            seekStream: seekStream,
            showText: showProgressText,
          ),
          Row(
            children: [
              CustomPlayerPlayButton(controller: controller),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions,
                ),
              ),
              const SizedBox(width: 8),
              if (showVolume) CustomPlayerVolume(controller: controller),
              if (showSpeed)
                CustomPlayerPlaySpeedButton(controller: controller),
              if (showMiniScreen)
                CustomPlayerMiniScreenButton(controller: controller),
              if (showFullScreen)
                CustomPlayerFullScreenButton(controller: controller),
            ],
          ),
        ],
      ),
    );
  }
}

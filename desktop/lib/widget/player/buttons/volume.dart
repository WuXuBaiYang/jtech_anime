import 'dart:math';

import 'package:action_slider/action_slider.dart';
import 'package:flutter/material.dart';
import 'package:jtech_anime_base/base.dart';

/*
* 自定义视频播放器控制层-音量按钮
* @author wuxubaiyang
* @Time 2023/10/7 9:38
*/
class CustomPlayerControlsVolumeButton extends StatefulWidget {
  // 按钮尺寸
  final Size size;

  // 控制器
  final CustomVideoPlayerController controller;

  const CustomPlayerControlsVolumeButton({
    super.key,
    required this.controller,
    this.size = const Size(145, 25),
  });

  @override
  State<StatefulWidget> createState() =>
      _CustomPlayerControlsVolumeButtonState();
}

/*
* 自定义视频播放器控制层-音量按钮-状态
* @author wuxubaiyang
* @Time 2023/10/7 9:41
*/
class _CustomPlayerControlsVolumeButtonState
    extends State<CustomPlayerControlsVolumeButton> {
  // 滚动条控制器
  final sliderController = ActionSliderController(anchorPosition: 1);

  // 音量调节按钮图标集合
  final volumeIcons = [
    FontAwesomeIcons.volumeXmark,
    FontAwesomeIcons.volumeOff,
    FontAwesomeIcons.volumeLow,
    FontAwesomeIcons.volumeHigh,
  ];

  @override
  void initState() {
    super.initState();
    // 监听音量变化并保持控制栏显示
    final controller = widget.controller;
    controller.stream.volume.listen((_) {
      controller.setControlVisible(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final controller = widget.controller;
    return StreamBuilder<double>(
      stream: controller.stream.volume,
      builder: (_, snap) {
        final volume = snap.data ?? 1;
        final length = volumeIcons.length - 1;
        final index = (volume * length).ceil();
        return ConstrainedBox(
          constraints: BoxConstraints.loose(size),
          child: ActionSlider.standard(
            borderWidth: 0,
            boxShadow: const [],
            height: size.height,
            controller: sliderController,
            backgroundColor: Colors.white10,
            icon: Icon(volumeIcons[min(index, length)],
                color: Colors.white, size: size.height * 0.4),
            customBackgroundBuilder: (_, state, child) {
              final offset = size.height / 2;
              return ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Row(
                  children: [
                    Container(width: offset, color: kPrimaryColor),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: state.position,
                        minHeight: size.height,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                    SizedBox(width: offset),
                  ],
                ),
              );
            },
            stateChangeCallback: (_, state, __) {
              final position = state.position;
              final index = state.slidingState.index;
              if (index == 0) controller.setVolume(position * 100);
              if (index == 1) sliderController.setAnchorPosition(position);
            },
          ),
        );
      },
    );
  }
}

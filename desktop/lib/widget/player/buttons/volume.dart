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
    this.size = const Size(140, 40),
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
  // 音量调节按钮显示控制
  final controlVolume = ValueChangeNotifier<bool>(false);

  // 音量调节按钮图标集合
  final volumeIcons = [
    FontAwesomeIcons.volumeXmark,
    FontAwesomeIcons.volumeOff,
    FontAwesomeIcons.volumeLow,
    FontAwesomeIcons.volumeHigh,
  ];

  // 缓存上一次的音量
  double? lastVolume;

  @override
  void initState() {
    super.initState();
    // 监听音量变化并保持控制栏显示
    widget.controller.stream.volume.listen((_) {
      widget.controller.setControlVisible(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return MouseRegion(
      onExit: (_) => controlVolume.setValue(false),
      onEnter: (_) => controlVolume.setValue(true),
      child: ValueListenableBuilder<bool>(
        valueListenable: controlVolume,
        builder: (_, visible, __) {
          return StreamBuilder<double>(
            stream: controller.stream.volume,
            builder: (_, snap) {
              final volume = (snap.data ?? 100) / 100;
              // 根据百分比从四个图标中选择, 0%为静音
              final iconData = volume == 0
                  ? volumeIcons[0]
                  : volumeIcons[
                      (volume * (volumeIcons.length - 2) + 1).toInt()];
              return Stack(
                children: [
                  _buildVolumeSlider(visible, volume),
                  IconButton(
                    icon: Icon(iconData),
                    onPressed: () {
                      double temp = 0;
                      if (volume > 0) {
                        lastVolume = volume;
                      } else {
                        temp = lastVolume ?? 0;
                      }
                      controller.setVolume(temp * 100);
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // 构建音量进度条
  Widget _buildVolumeSlider(bool visible, double volume) {
    final size = widget.size;
    final controller = widget.controller;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      constraints: BoxConstraints(
          maxWidth: visible ? size.width : 0, maxHeight: size.height),
      alignment: Alignment.centerRight,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox.fromSize(
          size: Size(size.width - 30, size.height),
          child: SliderTheme(
            data: const SliderThemeData(
              trackHeight: 2,
              overlayShape: RoundSliderOverlayShape(overlayRadius: 18),
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: volume,
              divisions: 100,
              label: '${(volume * 100).toInt()}%',
              onChanged: (v) => controller.setVolume(v * 100),
            ),
          ),
        ),
      ),
    );
  }
}

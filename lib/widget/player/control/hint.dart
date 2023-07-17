import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jtech_anime/common/notifier.dart';
import 'package:jtech_anime/widget/player/controller.dart';
import 'layer.dart';

/*
* 自定义视频播放器，提示层
* @author wuxubaiyang
* @Time 2023/7/17 15:52
*/
class CustomVideoPlayerHintLayer extends StatelessWidget
    with CustomVideoPlayerLayer {
  // 控制器
  final CustomVideoPlayerController controller;

  // 弹出层背景色
  final Color overlayColor;

  // 音量显示隐藏
  final ValueChangeNotifier<bool> showVolume;

  // 亮度显示隐藏
  final ValueChangeNotifier<bool> showBrightness;

  // 倍速显示隐藏
  final ValueChangeNotifier<bool> showSpeed;

  CustomVideoPlayerHintLayer({
    super.key,
    required this.controller,
    required this.overlayColor,
    required this.showVolume,
    required this.showBrightness,
    required this.showSpeed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        buildAnimeShow(
          showVolume,
          _buildHintProgress(
            controller.volume,
            FontAwesomeIcons.volumeLow,
          ),
        ),
        buildAnimeShow(
          showBrightness,
          _buildHintProgress(
            controller.brightness,
            FontAwesomeIcons.sun,
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: buildAnimeShow(
            showSpeed,
            _buildHintSpeed(),
          ),
        ),
      ],
    );
  }

  // 构建显示进度条
  Widget _buildHintProgress(
      ValueChangeNotifier<double> notifier, IconData iconData) {
    return SizedBox.fromSize(
      size: const Size(180, 60),
      child: Card(
        color: overlayColor,
        clipBehavior: Clip.hardEdge,
        margin: const EdgeInsets.all(14),
        child: ValueListenableBuilder<double>(
          valueListenable: notifier,
          builder: (_, value, __) {
            return Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  child: LinearProgressIndicator(
                    value: value,
                    backgroundColor: Colors.transparent,
                  ),
                ),
                Icon(iconData, size: 14),
              ],
            );
          },
        ),
      ),
    );
  }

  // 构建倍速
  Widget _buildHintSpeed() {
    return Card(
      color: overlayColor,
      margin: const EdgeInsets.all(14),
      child: const Padding(
        padding: EdgeInsets.all(14),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('正在快进'),
            SizedBox(width: 4),
            Icon(FontAwesomeIcons.anglesRight),
          ],
        ),
      ),
    );
  }
}

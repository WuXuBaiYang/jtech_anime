import 'package:flutter/material.dart';
import 'package:jtech_anime_base/base.dart';

/*
* 自定义视频播放器控制层-倍速按钮
* @author wuxubaiyang
* @Time 2023/10/7 9:38
*/
class CustomPlayerControlsSpeedButton extends StatefulWidget {
  // 按钮尺寸
  final Size size;

  // 控制器
  final CustomVideoPlayerController controller;

  const CustomPlayerControlsSpeedButton({
    super.key,
    required this.controller,
    this.size = const Size(140, 40),
  });

  @override
  State<StatefulWidget> createState() =>
      _CustomPlayerControlsSpeedButtonState();
}

/*
* 自定义视频播放器控制层-倍速按钮-状态
* @author wuxubaiyang
* @Time 2023/10/7 9:41
*/
class _CustomPlayerControlsSpeedButtonState
    extends State<CustomPlayerControlsSpeedButton> {
  // 播放倍速按钮显示控制
  final controlSpeed = ValueChangeNotifier<bool>(false);

  // 倍速调节按钮图标集合
  final speedIcons = [
    FontAwesomeIcons.gauge,
    FontAwesomeIcons.gaugeHigh,
    FontAwesomeIcons.gaugeHigh,
    FontAwesomeIcons.gaugeHigh,
  ];

  @override
  void initState() {
    super.initState();
    // 监听倍速变化并保持控制栏显示
    widget.controller.stream.rate.listen((_) {
      widget.controller.setControlVisible(true);
      _showSpeedControl();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return ValueListenableBuilder<bool>(
      valueListenable: controlSpeed,
      builder: (_, visible, __) {
        return StreamBuilder<double>(
          stream: controller.stream.rate,
          builder: (_, snap) {
            final rate = snap.data ?? 1.0;
            final iconData = speedIcons[rate.toInt() - 1];
            return Stack(
              children: [
                _buildSpeedSlider(visible, rate),
                IconButton(
                  icon: Icon(iconData),
                  onPressed: () {
                    if (visible) controller.setRate(1.0);
                    _showSpeedControl();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 构建倍速进度条
  Widget _buildSpeedSlider(bool visible, double rate) {
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
          child: Slider(
            min: 1,
            max: 4,
            value: rate,
            divisions: 3,
            label: '${rate}x',
            onChanged: controller.setRate,
          ),
        ),
      ),
    );
  }

  // 显示倍速控制状态并在一定时间后关闭
  void _showSpeedControl() {
    controlSpeed.setValue(true);
    Debounce.c(
      () => controlSpeed.setValue(false),
      'controlSpeed',
    );
  }
}

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:jtech_anime_base/base.dart';

/*
* 自定义播放器控制层-底部
* @author wuxubaiyang
* @Time 2023/8/28 10:57
*/
class CustomPlayerControlsBottom extends StatefulWidget {
  // 播放器控制器
  final CustomVideoPlayerController controller;

  // 播放进度控制
  final Stream<Duration?>? seekStream;

  // 扩展组件
  final List<Widget> actions;

  const CustomPlayerControlsBottom({
    super.key,
    required this.controller,
    this.seekStream,
    this.actions = const [],
  });

  @override
  State<StatefulWidget> createState() => _CustomPlayerControlsBottomState();
}

/*
* 自定义播放器控制层-底部-状态
* @author wuxubaiyang
* @Time 2023/8/28 10:57
*/
class _CustomPlayerControlsBottomState
    extends State<CustomPlayerControlsBottom> {
  // 临时进度条拖动监听
  final tempProgress = ValueChangeNotifier<Duration?>(null);

  // 音量调节按钮显示控制
  final controlVolume = ValueChangeNotifier<bool>(false);

  // 音量调节按钮显示控制
  final controlSpeed = ValueChangeNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    // 播放器控制器
    final controller = widget.controller;
    // 监听进度变化
    widget.seekStream?.listen((e) {
      if (e == null && tempProgress.value != null) {
        _delaySeekVideo(tempProgress.value!);
      } else {
        tempProgress.setValue(e);
      }
    });
    // 监听音量变化
    VolumeTool.stream.listen((_) {
      controller.setControlVisible(true);
      _showVolumeControl();
    });
    // 监听倍速播放变化
    controller.stream.rate.listen((_) {
      controller.setControlVisible(true);
      _showSpeedControl();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: IconButtonTheme(
        data: const IconButtonThemeData(
          style: ButtonStyle(
            iconSize: MaterialStatePropertyAll(20),
            iconColor: MaterialStatePropertyAll(Colors.white),
          ),
        ),
        child: Container(
          color: Colors.black38,
          child: GestureDetector(
            onTap: () {},
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(14).copyWith(top: 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProgressAction(),
                  Row(
                    children: [
                      _buildPlayAction(),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: widget.actions,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildSpeedButton(),
                      const SizedBox(width: 8),
                      _buildVolumeAction(),
                      const SizedBox(width: 8),
                      _buildFullscreenAction(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 构建底部状态播放按钮
  Widget _buildPlayAction() {
    final controller = widget.controller;
    return StreamBuilder<bool>(
      stream: controller.stream.playing,
      builder: (_, snap) {
        final playing = controller.state.playing;
        final icon = playing ? FontAwesomeIcons.pause : FontAwesomeIcons.play;
        return IconButton(
            icon: Icon(icon), onPressed: controller.resumeOrPause);
      },
    );
  }

  // 构建底部
  Widget _buildProgressAction() {
    final controller = widget.controller;
    const textStyle = TextStyle(color: Colors.white54, fontSize: 12);
    return SliderTheme(
      data: const SliderThemeData(
        trackHeight: 2,
        thumbShape: RoundSliderThumbShape(
          enabledThumbRadius: 6,
        ),
      ),
      child: ValueListenableBuilder<Duration?>(
        valueListenable: tempProgress,
        builder: (_, temp, __) {
          return StreamBuilder<Duration>(
            stream: controller.stream.position,
            builder: (_, snap) {
              final buffer = controller.state.buffer;
              final total = controller.state.duration;
              final progress = temp ?? controller.state.position;
              return Row(
                children: [
                  Text(progress.format(DurationPattern.fullTime),
                      style: textStyle),
                  Expanded(
                    child: Slider(
                      inactiveColor: Colors.black26,
                      max: max(total.inMilliseconds.toDouble(), 0),
                      value: max(progress.inMilliseconds.toDouble(), 0),
                      secondaryActiveColor: kPrimaryColor.withOpacity(0.3),
                      secondaryTrackValue:
                          max(buffer.inMilliseconds.toDouble(), 0),
                      onChanged: (v) => tempProgress
                          .setValue(Duration(milliseconds: v.toInt())),
                      onChangeEnd: (v) =>
                          _delaySeekVideo(Duration(milliseconds: v.toInt())),
                    ),
                  ),
                  Text(total.format(DurationPattern.fullTime),
                      style: textStyle),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // 倍速调节按钮图标集合
  final speedIcons = [
    FontAwesomeIcons.gauge,
    FontAwesomeIcons.gaugeHigh,
    FontAwesomeIcons.gaugeHigh,
    FontAwesomeIcons.gaugeHigh,
  ];

  // 构建倍速调节组件
  Widget _buildSpeedButton() {
    const size = Size(140, 40);
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
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  constraints: BoxConstraints(
                      maxWidth: visible ? size.width : 0,
                      maxHeight: size.height),
                  alignment: Alignment.centerRight,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox.fromSize(
                      size: Size(size.width - 30, size.height),
                      child: SliderTheme(
                        data: const SliderThemeData(
                          trackHeight: 2,
                          overlayShape:
                              RoundSliderOverlayShape(overlayRadius: 18),
                          thumbShape:
                              RoundSliderThumbShape(enabledThumbRadius: 8),
                        ),
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
                  ),
                ),
                IconButton(
                  icon: Icon(iconData),
                  onPressed: () {
                    if (controlSpeed.value) controller.setRate(1.0);
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

  // 音量调节按钮图标集合
  final volumeIcons = [
    FontAwesomeIcons.volumeXmark,
    FontAwesomeIcons.volumeOff,
    FontAwesomeIcons.volumeLow,
    FontAwesomeIcons.volumeHigh,
  ];

  // 构建音量控制按钮
  Widget _buildVolumeAction() {
    const size = Size(140, 40);
    return ValueListenableBuilder<bool>(
      valueListenable: controlVolume,
      builder: (_, visible, __) {
        return StreamBuilder<double>(
          stream: VolumeTool.stream,
          builder: (_, snap) {
            final volume = snap.data ?? 0.5;
            // 根据百分比从四个图标中选择, 0%为静音
            final iconData = volume == 0
                ? volumeIcons[0]
                : volumeIcons[(volume * (volumeIcons.length - 2) + 1).toInt()];
            return Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  constraints: BoxConstraints(
                      maxWidth: visible ? size.width : 0,
                      maxHeight: size.height),
                  alignment: Alignment.centerRight,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox.fromSize(
                      size: Size(size.width - 30, size.height),
                      child: SliderTheme(
                        data: const SliderThemeData(
                          trackHeight: 2,
                          overlayShape:
                              RoundSliderOverlayShape(overlayRadius: 18),
                          thumbShape:
                              RoundSliderThumbShape(enabledThumbRadius: 8),
                        ),
                        child: Slider(
                          value: volume,
                          divisions: 100,
                          onChanged: VolumeTool.set,
                          label: '${(volume * 100).toInt()}%',
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(iconData),
                  onPressed: () {
                    if (controlVolume.value) VolumeTool.set(0);
                    _showVolumeControl();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 构建全屏按钮
  Widget _buildFullscreenAction() {
    final controller = widget.controller;
    return ValueListenableBuilder<bool>(
      valueListenable: controller.controlFullscreen,
      builder: (_, expanded, __) {
        return IconButton(
          icon: Icon(
              expanded ? FontAwesomeIcons.compress : FontAwesomeIcons.expand),
          onPressed: () => controller.toggleFullscreen(),
        );
      },
    );
  }

  // 跳转到视频位置
  Future<void> _delaySeekVideo(Duration duration) async {
    await widget.controller.seekTo(duration);
    await Future.delayed(const Duration(milliseconds: 100));
    tempProgress.setValue(null);
  }

  // 显示音量控制状态并在一定时间后关闭
  void _showVolumeControl() {
    controlVolume.setValue(true);
    Debounce.c(
      () => controlVolume.setValue(false),
      'controlVolume',
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

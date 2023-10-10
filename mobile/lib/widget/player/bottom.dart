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

  @override
  void initState() {
    super.initState();
    // 监听进度变化
    widget.seekStream?.listen((e) {
      if (e == null && tempProgress.value != null) {
        _delaySeekVideo(tempProgress.value!);
      } else {
        tempProgress.setValue(e);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: GestureDetector(
          onTap: () {},
          onDoubleTap: () {},
          onLongPressEnd: (_) {},
          onLongPressStart: (_) {},
          onVerticalDragEnd: (_) {},
          onHorizontalDragEnd: (_) {},
          onVerticalDragStart: (_) {},
          onVerticalDragUpdate: (_) {},
          onHorizontalDragStart: (_) {},
          onHorizontalDragUpdate: (_) {},
          behavior: HitTestBehavior.opaque,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProgressAction(),
              Row(
                children: [
                  _buildPlayAction(),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: widget.actions,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildPlayVolumeAction(),
                  _buildPlaySpeedAction(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 构建播放进度条
  Widget _buildProgressAction() {
    final controller = widget.controller;
    const textStyle = TextStyle(color: Colors.white54, fontSize: 12);
    return ValueListenableBuilder<Duration?>(
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
                    onChangeStart: (_) =>
                        controller.setControlVisible(true, ongoing: true),
                    onChanged: (v) => tempProgress
                        .setValue(Duration(milliseconds: v.toInt())),
                    onChangeEnd: (v) =>
                        _delaySeekVideo(Duration(milliseconds: v.toInt())),
                  ),
                ),
                Text(total.format(DurationPattern.fullTime), style: textStyle),
              ],
            );
          },
        );
      },
    );
  }

  // 构建底部状态播放按钮
  Widget _buildPlayAction() {
    final controller = widget.controller;
    return StreamBuilder<bool>(
      stream: controller.stream.playing,
      builder: (_, snap) {
        final playing = controller.state.playing;
        return IconButton(
          onPressed: () {
            controller.setControlVisible(true);
            controller.resumeOrPause();
          },
          icon: Icon(playing ? FontAwesomeIcons.pause : FontAwesomeIcons.play),
        );
      },
    );
  }

  // 音量等级图标
  final volumeLevel = [
    FontAwesomeIcons.volumeXmark,
    FontAwesomeIcons.volumeOff,
    FontAwesomeIcons.volumeLow,
    FontAwesomeIcons.volumeHigh,
  ];

  // 记录静音前的音量
  double _lastVolume = 0;

  // 构建播放音量按钮
  Widget _buildPlayVolumeAction() {
    final controller = widget.controller;
    return StreamBuilder<double>(
      stream: controller.stream.volume,
      builder: (_, snap) {
        final volume = snap.data ?? 100;
        final length = volumeLevel.length - 1;
        final index = ((volume / 100) * length).ceil();
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(volumeLevel[min(index, length)]),
              onPressed: () {
                if (volume == 0) {
                  controller.setVolume(_lastVolume);
                } else {
                  _lastVolume = volume;
                  controller.setVolume(0);
                }
              },
            ),
            SizedBox.fromSize(
              size: const Size(140, 10),
              child: Slider(
                max: 100,
                value: volume,
                onChanged: (v) {
                  controller.setVolume(v);
                  controller.setControlVisible(true);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // 播放器倍速表
  final playSpeedMap = {
    0.5: FontAwesomeIcons.gaugeSimple,
    1.0: FontAwesomeIcons.gauge,
    2.0: FontAwesomeIcons.gaugeHigh,
    3.0: FontAwesomeIcons.gaugeHigh,
  };

  // 构建播放速度按钮
  Widget _buildPlaySpeedAction() {
    final controller = widget.controller;
    return StreamBuilder<double>(
      stream: controller.stream.rate,
      builder: (_, snap) {
        final rate = snap.data ?? 1.0;
        return PopupMenuButton<double>(
          elevation: 0,
          icon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(playSpeedMap[rate]),
              const SizedBox(width: 8),
              Text('${rate}x'),
            ],
          ),
          itemBuilder: (_) => playSpeedMap.entries
              .map<PopupMenuItem<double>>((e) => CheckedPopupMenuItem(
                    value: e.key,
                    checked: rate == e.key,
                    padding: EdgeInsets.zero,
                    child: Text('${e.key}x'),
                  ))
              .toList(),
          onSelected: controller.setRate,
        );
      },
    );
  }

  // 跳转到视频位置
  Future<void> _delaySeekVideo(Duration duration) async {
    await widget.controller.seekTo(duration);
    await Future.delayed(const Duration(milliseconds: 100));
    widget.controller.setControlVisible(true);
    tempProgress.setValue(null);
  }
}

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

  // 静音状态
  final controlMute = ValueChangeNotifier<bool>(false);

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
    // 监听静音状态变化
    controlMute.addListener(VolumeTool.mute);
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProgressAction(),
            Row(
              children: [
                _buildPlayAction(),
                const Spacer(),
                ...widget.actions,
                const SizedBox(width: 8),
                _buildRateAction(),
                const SizedBox(width: 8),
                _buildMuteAction(),
              ],
            ),
          ],
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
                      onChangeStart: (_) =>
                          controller.setControlVisible(true, ongoing: true),
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

  // 构建底部倍速按钮
  Widget _buildRateAction() {
    const itemHeight = 35.0;
    final controller = widget.controller;
    final ratios = [4.0, 3.0, 2.0, 1.0, 0.5];
    final offsetDY = ratios.length * itemHeight + 20;
    return StreamBuilder(
      stream: controller.stream.rate,
      builder: (_, snap) {
        bool showPopup = false;
        return StatefulBuilder(
          builder: (_, state) {
            return PopupMenuButton<double>(
              elevation: 0,
              color: Colors.black54,
              offset: Offset(0, -offsetDY),
              constraints: const BoxConstraints(maxWidth: 65),
              onCanceled: () => state(() {
                controller.setControlVisible(true);
                showPopup = false;
              }),
              onOpened: () => state(() {
                controller.setControlVisible(true, ongoing: true);
                showPopup = true;
              }),
              itemBuilder: (_) {
                return ratios.map<PopupMenuEntry<double>>((e) {
                  return PopupMenuItem(
                    value: e,
                    height: itemHeight,
                    child: Text('x$e'),
                  );
                }).toList();
              },
              onSelected: (v) {
                controller.setControlVisible(true);
                controller.setRate(v);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('x${snap.data ?? 1.0}'),
                  AnimatedRotation(
                    turns: showPopup ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.arrow_drop_down),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 构建底部静音按钮
  Widget _buildMuteAction() {
    final controller = widget.controller;
    return ValueListenableBuilder<bool>(
      valueListenable: controlMute,
      builder: (_, isMute, __) {
        return IconButton(
          onPressed: () {
            controlMute.setValue(!controlMute.value);
            controller.setControlVisible(true);
          },
          icon: Icon(isMute
              ? FontAwesomeIcons.volumeXmark
              : FontAwesomeIcons.volumeLow),
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

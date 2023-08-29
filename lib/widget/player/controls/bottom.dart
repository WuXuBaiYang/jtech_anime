import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jtech_anime/common/notifier.dart';
import 'package:jtech_anime/manage/theme.dart';
import 'package:jtech_anime/tool/date.dart';
import 'package:jtech_anime/tool/volume.dart';
import 'package:jtech_anime/widget/player/controller.dart';

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
                      max: total.inMilliseconds.toDouble(),
                      value: progress.inMilliseconds.toDouble(),
                      secondaryActiveColor: kPrimaryColor.withOpacity(0.3),
                      secondaryTrackValue: buffer.inMilliseconds.toDouble(),
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
    final controller = widget.controller;
    return StreamBuilder(
      stream: controller.stream.rate,
      builder: (_, snap) {
        return DropdownButton<double>(
          elevation: 0,
          value: snap.data ?? 1.0,
          underline: const SizedBox(),
          dropdownColor: Colors.black87,
          onTap: () => controller.setControlVisible(true, ongoing: true),
          items: [0.5, 1.0, 2.0, 3.0, 4.0]
              .map((e) => DropdownMenuItem<double>(
                    value: e,
                    child: Text('x$e'),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null) controller.setRate(v);
            controller.setControlVisible(true);
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

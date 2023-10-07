import 'dart:math';
import 'package:flutter/material.dart';
import 'package:jtech_anime_base/base.dart';
import 'buttons/speed.dart';
import 'buttons/volume.dart';

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
                    CustomPlayerControlsSpeedButton(
                      controller: widget.controller,
                    ),
                    const SizedBox(width: 8),
                    CustomPlayerControlsVolumeButton(
                      controller: widget.controller,
                    ),
                    const SizedBox(width: 8),
                    _buildFullscreenAction(),
                  ],
                ),
              ],
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
}

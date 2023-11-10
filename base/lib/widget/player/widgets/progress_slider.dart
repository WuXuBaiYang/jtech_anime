import 'dart:math';
import 'package:flutter/material.dart';
import 'package:jtech_anime_base/common/notifier.dart';
import 'package:jtech_anime_base/manage/theme.dart';
import 'package:jtech_anime_base/tool/date.dart';
import 'package:jtech_anime_base/widget/player/controller.dart';

/*
* 自定义播放器控制层-播放进度控制
* @author wuxubaiyang
* @Time 2023/11/6 14:29
*/
class CustomPlayerProgressSlider extends StatefulWidget {
  // 播放器控制器
  final CustomVideoPlayerController controller;

  // 播放进度控制
  final Stream<Duration?>? seekStream;

  // 是否展示两侧进度文本
  final bool showText;

  const CustomPlayerProgressSlider({
    super.key,
    required this.controller,
    this.seekStream,
    this.showText = true,
  });

  @override
  State<CustomPlayerProgressSlider> createState() =>
      _CustomPlayerProgressSliderState();
}

class _CustomPlayerProgressSliderState
    extends State<CustomPlayerProgressSlider> {
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
    final focusNode = FocusNode();
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
            if (widget.showText) {
              return Row(
                children: [
                  Text(progress.format(DurationPattern.fullTime),
                      style: textStyle),
                  Expanded(
                    child: _buildProgressSlider(progress,
                        buffer: buffer, total: total, focusNode: focusNode),
                  ),
                  Text(total.format(DurationPattern.fullTime),
                      style: textStyle),
                ],
              );
            }
            return _buildProgressSlider(progress,
                total: total, buffer: buffer, focusNode: focusNode);
          },
        );
      },
    );
  }

  // 构建进度条
  Widget _buildProgressSlider(
    Duration progress, {
    required Duration buffer,
    required Duration total,
    required FocusNode focusNode,
  }) {
    return Slider(
      focusNode: focusNode,
      inactiveColor: Colors.black26,
      max: max(total.inMilliseconds.toDouble(), 0),
      value: max(progress.inMilliseconds.toDouble(), 0),
      secondaryActiveColor: kPrimaryColor.withOpacity(0.3),
      secondaryTrackValue: max(buffer.inMilliseconds.toDouble(), 0),
      onChanged: (v) =>
          tempProgress.setValue(Duration(milliseconds: v.toInt())),
      onChangeEnd: (v) {
        _delaySeekVideo(Duration(milliseconds: v.toInt()));
        focusNode.unfocus();
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

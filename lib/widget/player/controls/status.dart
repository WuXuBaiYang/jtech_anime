import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jtech_anime/common/notifier.dart';
import 'package:jtech_anime/tool/debounce.dart';
import 'package:jtech_anime/widget/listenable_builders.dart';
import 'package:jtech_anime/widget/player/controller.dart';
import 'package:screen_brightness/screen_brightness.dart';

/*
* 自定义播放器控制层-状态层
* @author wuxubaiyang
* @Time 2023/8/28 10:19
*/
class CustomPlayerControlsStatus extends StatefulWidget {
  // 播放器控制器
  final CustomVideoPlayerController controller;

  // 音量控制
  final ValueChangeNotifier<double> volumeValue;

  // 倍速播放控制
  final ValueChangeNotifier<bool> controlPlaySpeed;

  const CustomPlayerControlsStatus({
    super.key,
    required this.controller,
    required this.volumeValue,
    required this.controlPlaySpeed,
  });

  @override
  State<StatefulWidget> createState() => _CustomPlayerControlsStatusState();
}

/*
* 自定义播放器控制层-状态层-状态
* @author wuxubaiyang
* @Time 2023/8/28 10:19
*/
class _CustomPlayerControlsStatusState
    extends State<CustomPlayerControlsStatus> {
  // 音量调整
  final controlVolume = ValueChangeNotifier<bool>(false);

  // 亮度调整
  final controlBrightness = ValueChangeNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    // 长按快进状态监听
    double speed = 1.0;
    widget.controlPlaySpeed.addListener(() {
      if (widget.controlPlaySpeed.value) {
        speed = widget.controller.state.rate;
        widget.controller.setRate(3.0);
      } else {
        widget.controller.setRate(speed);
        speed = 1.0;
      }
    });
    // 监听音量变化
    FlutterVolumeController.getVolume().then((v) {
      if (v != null) widget.volumeValue.setValue(v);
      widget.volumeValue.addListener(() {
        controlVolume.setValue(true);
        Debounce.c(
          delay: const Duration(milliseconds: 200),
          () => controlVolume.setValue(false),
          'updateVolume',
        );
      });
    });
    // 监听亮度变化
    ScreenBrightness().onCurrentBrightnessChanged.listen((_) {
      controlBrightness.setValue(true);
      Debounce.c(
        delay: const Duration(milliseconds: 200),
        () => controlBrightness.setValue(false),
        'updateBrightness',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          _buildVolume(),
          _buildPlaySpeed(),
          _buildBrightness(),
          _buildBuffingStatus(),
        ],
      ),
    );
  }

  // 构建长按播放倍速提示
  Widget _buildPlaySpeed() {
    return Align(
      alignment: Alignment.center,
      child: ValueListenableBuilder<bool>(
        valueListenable: widget.controlPlaySpeed,
        builder: (_, showPlaySpeed, __) {
          return AnimatedOpacity(
            opacity: showPlaySpeed ? 1.0 : 0,
            duration: const Duration(milliseconds: 150),
            child: const Card(
              elevation: 0,
              color: Colors.black38,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('快进中', style: TextStyle(fontSize: 14)),
                    SizedBox(width: 4),
                    Icon(FontAwesomeIcons.anglesRight, size: 18),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 控制音量变化
  Widget _buildVolume() {
    return Align(
      alignment: Alignment.centerLeft,
      child: ValueListenableBuilder2<bool, double>(
        first: controlVolume,
        second: widget.volumeValue,
        builder: (_, showVolume, value, __) {
          return _buildVerticalProgress(showVolume, value,
              icon: const Icon(FontAwesomeIcons.volumeLow));
        },
      ),
    );
  }

  // 控制亮度变化
  Widget _buildBrightness() {
    return Align(
      alignment: Alignment.centerRight,
      child: ValueListenableBuilder<bool>(
        valueListenable: controlBrightness,
        builder: (_, showBrightness, __) {
          return StreamBuilder<double>(
            stream: ScreenBrightness().onCurrentBrightnessChanged,
            builder: (_, snap) {
              final value = snap.data ?? 0;
              return _buildVerticalProgress(showBrightness, value,
                  icon: const Icon(FontAwesomeIcons.sun));
            },
          );
        },
      ),
    );
  }

  // 构建垂直进度条
  Widget _buildVerticalProgress(bool visible, double progress, {Widget? icon}) {
    return AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: const Duration(milliseconds: 150),
      child: Transform.rotate(
        angle: 270 * pi / 180,
        child: Card(
          elevation: 0,
          color: Colors.black38,
          clipBehavior: Clip.hardEdge,
          margin: const EdgeInsets.all(24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              SizedBox.fromSize(
                size: const Size(160, 40),
                child: LinearProgressIndicator(
                  backgroundColor: Colors.transparent,
                  value: progress,
                ),
              ),
              Padding(padding: const EdgeInsets.all(8), child: icon),
            ],
          ),
        ),
      ),
    );
  }

  // 构建缓冲状态提示
  Widget _buildBuffingStatus() {
    final controller = widget.controller;
    return Align(
      alignment: Alignment.center,
      child: StreamBuilder<bool>(
        stream: controller.stream.buffering,
        builder: (_, snap) {
          if (!(snap.data ?? false)) return const SizedBox();
          return const SizedBox.square(
            dimension: 35,
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

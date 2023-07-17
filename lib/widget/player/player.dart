import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jtech_anime/common/notifier.dart';
import 'package:jtech_anime/tool/tool.dart';
import 'package:jtech_anime/widget/listenable_builders.dart';
import 'package:jtech_anime/widget/player/control/control.dart';
import 'package:jtech_anime/widget/player/controller.dart';
import 'package:jtech_anime/widget/status_box.dart';
import 'package:video_player/video_player.dart';
import 'control/gesture.dart';

/*
* 视频播放器
* @author wuxubaiyang
* @Time 2023/7/12 13:35
*/
class CustomVideoPlayer extends StatefulWidget {
  // 视频控制器
  final CustomVideoPlayerController controller;

  // 动作条组件集合
  final List<Widget> actions;

  // 标题
  final Widget? title;

  // 状态为空时的占位图
  final Widget? placeholder;

  // 弹出层背景色
  final Color overlayColor;

  // 主色调
  final Color? primaryColor;

  const CustomVideoPlayer({
    super.key,
    required this.controller,
    this.title,
    this.placeholder,
    this.primaryColor,
    this.actions = const [],
    this.overlayColor = Colors.black26,
  });

  @override
  State<StatefulWidget> createState() => _CustomVideoPlayerState();
}

/*
* 视频播放器-状态
* @author wuxubaiyang
* @Time 2023/7/12 13:55
*/
class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  // 锁屏状态显示隐藏
  final showLock = ValueChangeNotifier<bool>(false);

  // 控制组件显示隐藏
  final showControl = ValueChangeNotifier<bool>(false);

  // 亮度组件显示隐藏
  final showBrightness = ValueChangeNotifier<bool>(false);

  // 音量组件显示隐藏
  final showVolume = ValueChangeNotifier<bool>(false);

  // 倍速组件显示隐藏
  final showSpeed = ValueChangeNotifier<bool>(false);

  // 显示隐藏的动画间隔
  final animeDuration = const Duration(milliseconds: 130);

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final primaryColor = widget.primaryColor;
    return Theme(
      data: ThemeData.dark(useMaterial3: true).copyWith(
        cardTheme: const CardTheme(elevation: 0),
        colorScheme: primaryColor != null
            ? ColorScheme.dark(primary: primaryColor)
            : null,
      ),
      child: ValueListenableBuilder2<PlayerState, bool>(
        first: controller,
        second: controller.locked,
        builder: (_, state, locked, __) {
          return Stack(
            alignment: Alignment.center,
            children: [
              _buildPlayerLayer(context, controller),
              _buildStateLayer(controller),
              if (!locked) Positioned.fill(child: _buildGestureLayer()),
              if (!locked) Positioned.fill(child: _buildHintLayer()),
              if (!locked) Positioned.fill(child: _buildControlLayer()),
              Positioned.fill(child: _buildLockLayer(controller, locked)),
            ],
          );
        },
      ),
    );
  }

  // 构建播放器层
  Widget _buildPlayerLayer(
      BuildContext context, CustomVideoPlayerController controller) {
    final videoController = controller.videoController;
    if (videoController == null) return const SizedBox();
    return ValueListenableBuilder(
      valueListenable: controller.ratio,
      builder: (_, videoRatio, __) {
        final ratio = controller.getAspectRatio(context);
        return AspectRatio(
          aspectRatio: ratio,
          child: VideoPlayer(videoController),
        );
      },
    );
  }

  // 构建状态层
  Widget _buildStateLayer(CustomVideoPlayerController controller) {
    // 如果是播放中则不显示状态
    if (controller.isPlaying) return const SizedBox();
    // 如果无状态则显示占位图
    if (controller.value == PlayerState.none) {
      return widget.placeholder ?? const SizedBox();
    }
    // 如果是暂停/准备播放则展示播放按钮
    if (controller.isPause || controller.isReady2Play) {
      return const Icon(FontAwesomeIcons.play, size: 45);
    }
    // 展示其他状态
    final text = {
      PlayerState.loading: '正在加载视频~',
      PlayerState.buffering: '正在缓冲视频~',
    }[controller.value];
    return StatusBox(
      status: StatusBoxStatus.loading,
      title: Text(text ?? ''),
      color: Colors.white54,
      animSize: 35,
      space: 14,
    );
  }

  // 构建手势操作层
  Widget _buildGestureLayer() {
    return CustomVideoPlayerGestureLayer(
      controller: widget.controller,
      onTap: () => _show(showControl),
      onSpeed: (show, _) => _showProtrudeView(showSpeed, show),
      onVolume: (show, _) => _showProtrudeView(showVolume, show),
      onBrightness: (show, _) => _showProtrudeView(showBrightness, show),
    );
  }

  // 构建提示消息层
  Widget _buildHintLayer() {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        _buildAnimeShow(
          showVolume,
          _buildHintProgress(
            widget.controller.volume,
            FontAwesomeIcons.volumeLow,
          ),
        ),
        _buildAnimeShow(
          showBrightness,
          _buildHintProgress(
            widget.controller.brightness,
            FontAwesomeIcons.sun,
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: _buildAnimeShow(
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
    return SizedBox(
      width: 180,
      height: 55,
      child: Card(
        color: widget.overlayColor,
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
      color: widget.overlayColor,
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

  // 构建控制组件
  Widget _buildControlLayer() {
    return _buildAnimeShow(
      showControl,
      CustomVideoPlayerControlLayer(
        controller: widget.controller,
        onLocked: () => _show(showLock),
        overlayColor: widget.overlayColor,
      ),
    );
  }

  // 构建锁屏层
  Widget _buildLockLayer(CustomVideoPlayerController controller, bool locked) {
    if (!locked) return const SizedBox();
    return GestureDetector(
      onTap: () => _show(showLock),
      child: Container(
        color: Colors.transparent,
        child: _buildAnimeShow(
          showLock,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(FontAwesomeIcons.lock),
                onPressed: () => controller.setLocked(false),
              ),
              IconButton(
                icon: const Icon(FontAwesomeIcons.lock),
                onPressed: () => controller.setLocked(false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 展示组件并在一定时间后隐藏
  void _show(ValueChangeNotifier<bool> notifier) {
    notifier.setValue(true);
    Tool.debounce(() => notifier.setValue(false))();
  }

  // 构建可控显示隐藏组件
  Widget _buildAnimeShow(ValueChangeNotifier<bool> notifier, Widget child) {
    return ValueListenableBuilder<bool>(
      valueListenable: notifier,
      builder: (_, show, __) {
        return AnimatedOpacity(
          opacity: show ? 1 : 0,
          duration: animeDuration,
          child: child,
        );
      },
    );
  }

  // 展示突出组件（展示突出组件并隐藏其他组件）
  void _showProtrudeView(ValueChangeNotifier<bool> notifier, bool show) {
    // 展示重点组件
    notifier.setValue(show);
    // 如果控制组件本身是隐藏的则不做处理
    if (showControl.value) {
      if (show) {
        showControl.setValue(false);
      } else {
        _show(showControl);
      }
    }
  }
}

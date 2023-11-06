import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jtech_anime_base/common/notifier.dart';
import 'package:jtech_anime_base/manage/theme.dart';
import 'package:jtech_anime_base/widget/listenable_builders.dart';
import 'package:jtech_anime_base/widget/player/controller.dart';
import 'package:jtech_anime_base/widget/player/widgets/brightness.dart';
import 'package:jtech_anime_base/widget/player/widgets/progress.dart';
import 'bottom.dart';
import 'mini.dart';
import 'side.dart';
import 'status.dart';
import 'top.dart';

/*
* 自定义播放器控制层
* @author wuxubaiyang
* @Time 2023/11/6 15:10
*/
class CustomPlayerControls extends StatefulWidget {
  // 控制器
  final CustomVideoPlayerController controller;

  // 自定义样式
  final ThemeData? theme;

  // 标题
  final Widget? title;

  // 顶部leading
  final Widget? leading;

  // 副标题
  final Widget? subTitle;

  // 顶部按钮集合
  final List<Widget> topActions;

  // 底部按钮集合
  final List<Widget> bottomActions;

  // 缓冲状态大小
  final double? buffingSize;

  const CustomPlayerControls({
    super.key,
    required this.controller,
    this.theme,
    this.title,
    this.leading,
    this.subTitle,
    this.buffingSize,
    this.topActions = const [],
    this.bottomActions = const [],
  });

  // 播放器样式
  ThemeData getTheme(BuildContext context) =>
      theme ??
      Theme.of(context).copyWith(
        colorScheme: ColorScheme.dark(
          primary: kPrimaryColor,
          secondary: kSecondaryColor,
          onPrimary: Colors.white,
        ),
        iconButtonTheme: const IconButtonThemeData(
          style: ButtonStyle(
            iconSize: MaterialStatePropertyAll(20),
            iconColor: MaterialStatePropertyAll(Colors.white),
          ),
        ),
        sliderTheme: const SliderThemeData(
          trackHeight: 2,
          thumbShape: RoundSliderThumbShape(
            enabledThumbRadius: 6,
          ),
          overlayShape: RoundSliderOverlayShape(
            overlayRadius: 14,
          ),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
          size: 20,
        ),
      );

  @override
  State<StatefulWidget> createState() => _CustomPlayerControlsMobileState();
}

/*
* 自定义播放器控制层-移动端
* @author wuxubaiyang
* @Time 2023/11/6 16:54
*/
class _CustomPlayerControlsMobileState extends State<CustomPlayerControls> {
  // 倍速播放状态展示控制
  final visiblePlaySpeed = ValueChangeNotifier<bool>(false);

  // 播放进度控制
  final playerSeekStream = StreamController<Duration?>.broadcast();

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: widget.getTheme(context),
      child: _buildControls(context),
    );
  }

  // 构建控制器
  Widget _buildControls(BuildContext context) {
    Duration? tempPosition;
    final controller = widget.controller;
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width, screenHeight = screenSize.height;
    return GestureDetector(
      // 单击
      onTap: controller.toggleControlVisible,
      // 双击
      onDoubleTap: () {
        if (controller.isScreenLocked) return;
        widget.controller.resumeOrPause().then((playing) {
          if (playing) controller.setControlVisible(false);
        });
      },
      // 长点击
      onLongPressStart: (_) {
        if (!controller.state.playing || controller.isScreenLocked) return;
        visiblePlaySpeed.setValue(true);
        HapticFeedback.vibrate();
      },
      onLongPressEnd: (_) => visiblePlaySpeed.setValue(false),
      // 垂直滑动
      onVerticalDragStart: (_) {
        if (controller.isScreenLocked) return;
        controller.setControlVisible(false);
      },
      onVerticalDragUpdate: (details) {
        if (controller.isScreenLocked) return;
        // 区分左右屏
        final offset = details.delta.dy / screenHeight;
        if (details.globalPosition.dx > screenWidth / 2) {
          controller.setVolume(controller.currentVolume - offset);
        } else {
          controller.setBrightness(controller.currentBrightness - offset);
        }
      },
      onHorizontalDragStart: (_) {
        if (controller.isScreenLocked) return;
        controller.setControlVisible(true, ongoing: true);
      },
      onHorizontalDragUpdate: (details) {
        if (controller.isScreenLocked) return;
        final current = tempPosition?.inMilliseconds ??
            controller.state.position.inMilliseconds;
        final total = controller.state.duration.inMilliseconds;
        final value =
            current + (details.delta.dx / screenHeight * total * 0.35).toInt();
        if (value < 0 || value > total) return;
        tempPosition = Duration(milliseconds: value);
        playerSeekStream.add(tempPosition);
      },
      onHorizontalDragEnd: (_) {
        playerSeekStream.add(null);
        tempPosition = null;
      },
      child: Stack(
        children: [
          CustomPlayerBrightness(controller: widget.controller),
          _buildVisibleControls(),
          _buildControlsStatus(),
        ],
      ),
    );
  }

  // 构建控制层
  Widget _buildVisibleControls() {
    final controller = widget.controller;
    return ValueListenableBuilder2<bool, bool>(
      first: controller.controlVisible,
      second: controller.screenLocked,
      builder: (_, visible, locked, __) {
        return AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: const Duration(milliseconds: 80),
          child: Container(
            color: Colors.black38,
            child: Stack(
              children: [
                if (!locked) ...[
                  CustomPlayerControlsTop(
                    controller: controller,
                    title: widget.title,
                    leading: widget.leading,
                    subTitle: widget.subTitle,
                    actions: widget.topActions,
                  ),
                  CustomPlayerControlsBottom(
                    showMiniScreen: false,
                    showFullScreen: false,
                    controller: controller,
                    actions: widget.bottomActions,
                    seekStream: playerSeekStream.stream,
                  ),
                ],
                CustomPlayerControlsSide(
                  controller: controller,
                ),
                if (locked)
                  CustomPlayerProgress(
                    controller: controller,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 构建状态曾
  Widget _buildControlsStatus() {
    return ValueListenableBuilder(
      valueListenable: visiblePlaySpeed,
      builder: (_, visible, __) {
        return CustomPlayerControlsStatus(
          visiblePlaySpeed: visible,
          controller: widget.controller,
          statusSize: widget.buffingSize,
        );
      },
    );
  }
}

/*
* 自定义播放器控制层-桌面端
* @author wuxubaiyang
* @Time 2023/11/6 16:54
*/
class _CustomPlayerControlsDesktopState extends State<CustomPlayerControls> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: widget.getTheme(context),
      child: _buildControls(),
    );
  }

  // 构建控制器
  Widget _buildControls() {
    final controller = widget.controller;
    return GestureDetector(
      onTap: () => widget.controller.resumeOrPause().then((playing) {
        if (playing) controller.setControlVisible(true);
      }),
      onDoubleTap: () => controller.toggleFullscreen(),
      child: MouseRegion(
        onHover: (_) => controller.setControlVisible(true),
        onEnter: (_) => controller.setControlVisible(true),
        onExit: (_) => controller.setControlVisible(false),
        child: Stack(
          children: [
            CustomPlayerBrightness(controller: widget.controller),
            _buildVisibleControls(),
            CustomPlayerControlsStatus(
              showVolume: false,
              showPlaySpeed: false,
              showBrightness: false,
              controller: widget.controller,
              statusSize: widget.buffingSize,
            ),
          ],
        ),
      ),
    );
  }

  // 顶部自定义装饰器
  final topDecoration = const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color.fromRGBO(0, 0, 0, 0.65),
        Color.fromRGBO(0, 0, 0, 0),
      ],
    ),
  );

  // 底部自定义装饰器
  final bottomDecoration = const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [
        Color.fromRGBO(0, 0, 0, 0.75),
        Color.fromRGBO(0, 0, 0, 0),
      ],
    ),
  );

  // 构建控制层
  Widget _buildVisibleControls() {
    final controller = widget.controller;
    return ValueListenableBuilder3<bool, bool, bool>(
      first: controller.controlVisible,
      second: controller.screenLocked,
      third: controller.miniWindow,
      builder: (_, visible, locked, isMiniWindow, __) {
        return AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: const Duration(milliseconds: 80),
          child: Stack(
            children: [
              if (isMiniWindow)
                CustomPlayerControlsMini(
                  controller: controller,
                )
              else ...[
                CustomPlayerControlsTop(
                  title: widget.title,
                  controller: controller,
                  leading: widget.leading,
                  subTitle: widget.subTitle,
                  decoration: topDecoration,
                  actions: widget.topActions,
                ),
                CustomPlayerControlsBottom(
                  controller: controller,
                  decoration: bottomDecoration,
                  actions: widget.bottomActions,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

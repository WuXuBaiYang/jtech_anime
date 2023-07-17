import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jtech_anime/widget/player/controller.dart';
import 'layer.dart';

/*
* 自定义视频播放器，控制层
* @author wuxubaiyang
* @Time 2023/7/17 11:00
*/
class CustomVideoPlayerControlLayer extends StatefulWidget {
  // 控制器
  final CustomVideoPlayerController controller;

  // 锁定回调
  final VoidCallback? onLocked;

  // 弹出层背景色
  final Color overlayColor;

  const CustomVideoPlayerControlLayer({
    super.key,
    required this.overlayColor,
    required this.controller,
    this.onLocked,
  });

  @override
  State<CustomVideoPlayerControlLayer> createState() =>
      _CustomVideoPlayerControlLayerState();
}

class _CustomVideoPlayerControlLayerState
    extends State<CustomVideoPlayerControlLayer> with CustomVideoPlayerLayer {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: _buildTopBar(),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: _buildBottomBar(),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: _buildSideBar(),
        ),
      ],
    );
  }

  // 构建顶部条
  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          stops: const [1, 0],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [widget.overlayColor, widget.overlayColor.withOpacity(0.2)],
        ),
      ),
      child: Text('顶部导航条'),
    );
  }

  // 构建底部条
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          stops: const [0, 1],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [widget.overlayColor, widget.overlayColor.withOpacity(0.2)],
        ),
      ),
      child: Text('底部导航条'),
    );
  }

  // 构建侧边条
  Widget _buildSideBar() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () {
            widget.controller.setLocked(true);
            widget.onLocked?.call();
          },
          icon: const Icon(FontAwesomeIcons.lockOpen),
        ),
      ],
    );
  }
}

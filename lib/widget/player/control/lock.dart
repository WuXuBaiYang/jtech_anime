import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jtech_anime/widget/player/controller.dart';

/*
* 自定义视频播放器，锁定层
* @author wuxubaiyang
* @Time 2023/7/17 16:16
*/
class CustomVideoPlayerLockLayer extends StatefulWidget {
  // 控制器
  final CustomVideoPlayerController controller;

  // 已解锁回调
  final VoidCallback? onUnlock;

  // 点击事件
  final VoidCallback? onTap;

  const CustomVideoPlayerLockLayer({
    super.key,
    required this.controller,
    this.onUnlock,
    this.onTap,
  });

  @override
  State<CustomVideoPlayerLockLayer> createState() =>
      _CustomVideoPlayerLockLayerState();
}

class _CustomVideoPlayerLockLayerState
    extends State<CustomVideoPlayerLockLayer> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.controller.locked,
      builder: (_, locked, __) {
        if (!locked) return const SizedBox();
        return GestureDetector(
          onDoubleTap: () {},
          onTap: widget.onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(
                2,
                (i) => IconButton(
                  icon: const Icon(FontAwesomeIcons.lock),
                  onPressed: () {
                    widget.controller.setLocked(false);
                    widget.onUnlock?.call();
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

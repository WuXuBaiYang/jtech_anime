import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jtech_anime/common/notifier.dart';
import 'package:jtech_anime/widget/player/controller.dart';

import 'layer.dart';

/*
* 自定义视频播放器，锁定层
* @author wuxubaiyang
* @Time 2023/7/17 16:16
*/
class CustomVideoPlayerLockLayer extends StatefulWidget {
  // 控制器
  final CustomVideoPlayerController controller;

  // 锁定屏幕展示
  final ValueChangeNotifier<bool> showLock;

  // 已解锁回调
  final VoidCallback? onUnlock;

  const CustomVideoPlayerLockLayer({
    super.key,
    required this.controller,
    required this.showLock,
    this.onUnlock,
  });

  @override
  State<CustomVideoPlayerLockLayer> createState() =>
      _CustomVideoPlayerLockLayerState();
}

class _CustomVideoPlayerLockLayerState extends State<CustomVideoPlayerLockLayer>
    with CustomVideoPlayerLayer {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.controller.locked,
      builder: (_, locked, __) {
        if (!locked) return const SizedBox();
        return GestureDetector(
          onDoubleTap: () {},
          onTap: () => show(widget.showLock),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            color: Colors.transparent,
            child: buildAnimeShow(
              widget.showLock,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(FontAwesomeIcons.lock),
                    onPressed: () {
                      widget.controller.setLocked(false);
                      widget.showLock.setValue(false);
                      widget.onUnlock?.call();
                    },
                  ),
                  IconButton(
                    icon: const Icon(FontAwesomeIcons.lock),
                    onPressed: () {
                      widget.controller.setLocked(false);
                      widget.showLock.setValue(false);
                      widget.onUnlock?.call();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

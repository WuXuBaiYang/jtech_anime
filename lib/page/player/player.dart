import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jtech_anime/manage/router.dart';
import 'package:jtech_anime/manage/theme.dart';
import 'package:jtech_anime/model/anime.dart';
import 'package:lecle_yoyo_player/lecle_yoyo_player.dart';

// 初始化完成回调
typedef VideoInitCompletedCallback = void Function(
    VideoPlayerController controller);
// 选集切换回调
typedef ChangeVideoResourceCallback = void Function(ResourceItemModel item);

/*
* 视频播放器
* @author wuxubaiyang
* @Time 2023/7/12 13:35
*/
class CustomVideoPlayer extends StatefulWidget {
  // 视频地址
  final String url;

  // 标题
  final String? title;

  // 加载提示组件
  final Widget? loadingView;

  // 视频资源集合
  final List<List<ResourceItemModel>>? resources;

  // 初始化完成回调
  final VideoInitCompletedCallback? videoInitCompleted;

  // 选集切换回调
  final ChangeVideoResourceCallback? changeVideoResource;

  const CustomVideoPlayer({
    super.key,
    required this.url,
    this.title,
    this.resources,
    this.loadingView,
    this.videoInitCompleted,
    this.changeVideoResource,
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
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: YoYoPlayer(
        url: widget.url,
        // 16:9播放比例
        aspectRatio: 16 / 9,
        // 是否允许缓存文件
        allowCacheFile: true,
        // 播放器样式
        videoStyle: videoStyle,
        // 播放器加载样式
        videoLoadingStyle: loadingStyle,
        // 默认横屏展示
        displayFullScreenAfterInit: true,
        onCacheFileCompleted: (files) {},
        onCacheFileFailed: (error) {},
        onVideoInitCompleted: (controller) {
          widget.videoInitCompleted?.call(controller);
        },
        onFullScreen: (value) {},
      ),
      onWillPop: () async {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
        router.pop();
        return true;
      },
    );
  }

  // 播放器样式
  VideoStyle get videoStyle => VideoStyle(
        title: Text(widget.title ?? ''),
        actionBarPadding: EdgeInsets.zero,
        spaceBetweenBottomBarButtons: 14,
        actionBarBgColor: Colors.black.withOpacity(0.6),
        playIcon: const Icon(
          FontAwesomeIcons.play,
          color: Colors.white,
          size: 40,
        ),
        pauseIcon: const Icon(
          FontAwesomeIcons.pause,
          color: Colors.white,
          size: 40,
        ),
        backwardIcon: const Icon(
          FontAwesomeIcons.backward,
          color: Colors.white,
          size: 24,
        ),
        forwardIcon: const Icon(
          FontAwesomeIcons.forward,
          color: Colors.white,
          size: 24,
        ),
        progressIndicatorColors: VideoProgressColors(
          playedColor: kPrimaryColor,
        ),
        progressIndicatorPadding: const EdgeInsets.only(bottom: 8),
        bottomBarPadding:
            const EdgeInsets.symmetric(vertical: 4, horizontal: 14)
                .copyWith(top: 0),
        actions: [
          if (widget.resources != null)
            OutlinedButton(
              child: const Text('选集'),
              onPressed: () {
                /// 选集切换功能
              },
            ),
        ],
      );

  // 视频加载样式
  VideoLoadingStyle get loadingStyle => VideoLoadingStyle(
        loading: Center(
          child: widget.loadingView ??
              const Center(
                child: Text(
                  '视频加载中~',
                  style: TextStyle(color: Colors.white),
                ),
              ),
        ),
      );
}

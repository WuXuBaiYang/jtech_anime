import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jtech_anime/manage/router.dart';
import 'package:lecle_yoyo_player/lecle_yoyo_player.dart';

// 初始化完成回调
typedef VideoInitCompletedCallback = void Function(
    VideoPlayerController controller);

/*
* 视频播放器
* @author wuxubaiyang
* @Time 2023/7/12 13:35
*/
class CustomVideoPlayer extends StatefulWidget {
  // 视频地址
  final String url;

  // 加载提示组件
  final Widget? loadingView;

  // 初始化完成回调
  final VideoInitCompletedCallback? videoInitCompleted;

  const CustomVideoPlayer({
    super.key,
    required this.url,
    this.loadingView,
    this.videoInitCompleted,
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
  VideoStyle get videoStyle => const VideoStyle(
        qualityStyle: TextStyle(
          fontSize: 16,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        forwardAndBackwardBtSize: 30.0,
        playButtonIconSize: 40.0,
        playIcon: Icon(
          Icons.add_circle_outline_outlined,
          size: 40.0,
          color: Colors.white,
        ),
        pauseIcon: Icon(
          Icons.remove_circle_outline_outlined,
          size: 40.0,
          color: Colors.white,
        ),
        videoQualityPadding: EdgeInsets.all(5.0),
        fullscreenIcon: SizedBox(),
        orientation: [DeviceOrientation.landscapeLeft],
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

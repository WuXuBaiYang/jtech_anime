import 'package:flutter/material.dart';
import 'package:lecle_yoyo_player/lecle_yoyo_player.dart';
import 'package:lecle_yoyo_player/src/utils/utils.dart';
import 'package:video_player/video_player.dart';

/// Widget use to display the bottom bar buttons and the time texts
class PlayerBottomBar extends StatelessWidget {
  /// Constructor
  const PlayerBottomBar({
    Key? key,
    required this.controller,
    required this.showBottomBar,
    this.onPlayButtonTap,
    this.videoDuration = "00:00:00",
    this.videoSeek = "00:00:00",
    this.videoStyle = const VideoStyle(),
    this.onFastForward,
    this.onRewind,
  }) : super(key: key);

  /// The controller of the playing video.
  final VideoPlayerController controller;

  /// If set to [true] the bottom bar will appear and if you want that user can not interact with the bottom bar you can set it to [false].
  /// Default value is [true].
  final bool showBottomBar;

  /// The text to display the current position progress.
  final String videoSeek;

  /// The text to display the video's duration.
  final String videoDuration;

  /// The callback function execute when user tapped the play button.
  final void Function()? onPlayButtonTap;

  /// The model to provide custom style for the video display widget.
  final VideoStyle videoStyle;

  /// The callback function execute when user tapped the rewind button.
  final ValueChanged<VideoPlayerValue>? onRewind;

  /// The callback function execute when user tapped the forward button.
  final ValueChanged<VideoPlayerValue>? onFastForward;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: showBottomBar,
      child: Padding(
        padding: videoStyle.bottomBarPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            VideoProgressIndicator(
              controller,
              allowScrubbing: videoStyle.allowScrubbing ?? true,
              colors: videoStyle.progressIndicatorColors ??
                  const VideoProgressColors(
                    playedColor: Color.fromARGB(250, 0, 255, 112),
                  ),
              padding: videoStyle.progressIndicatorPadding ?? EdgeInsets.zero,
            ),
            Padding(
              padding: videoStyle.videoDurationsPadding ??
                  const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      videoSeek,
                      style: videoStyle.videoSeekStyle ??
                          const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0.0, -4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            controller.rewind().then((value) {
                              onRewind?.call(controller.value);
                            });
                          },
                          child: videoStyle.backwardIcon ??
                              Icon(
                                Icons.fast_rewind_rounded,
                                color: videoStyle.forwardIconColor,
                                size: videoStyle.forwardAndBackwardBtSize,
                              ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: videoStyle.spaceBetweenBottomBarButtons,
                          ),
                          child: InkWell(
                            onTap: onPlayButtonTap,
                            child: () {
                              var defaultIcon = Icon(
                                controller.value.isPlaying
                                    ? Icons.pause_circle_outline
                                    : Icons.play_circle_outline,
                                color: videoStyle.playButtonIconColor ??
                                    Colors.white,
                                size: videoStyle.playButtonIconSize ?? 35,
                              );

                              if (videoStyle.playIcon != null &&
                                  videoStyle.pauseIcon == null) {
                                return controller.value.isPlaying
                                    ? defaultIcon
                                    : videoStyle.playIcon;
                              } else if (videoStyle.pauseIcon != null &&
                                  videoStyle.playIcon == null) {
                                return controller.value.isPlaying
                                    ? videoStyle.pauseIcon
                                    : defaultIcon;
                              } else if (videoStyle.playIcon != null &&
                                  videoStyle.pauseIcon != null) {
                                return controller.value.isPlaying
                                    ? videoStyle.pauseIcon
                                    : videoStyle.playIcon;
                              }

                              return defaultIcon;
                            }(),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            controller.fastForward().then((value) {
                              onFastForward?.call(controller.value);
                            });
                          },
                          child: videoStyle.forwardIcon ??
                              Icon(
                                Icons.fast_forward_rounded,
                                color: videoStyle.forwardIconColor,
                                size: videoStyle.forwardAndBackwardBtSize,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      videoDuration,
                      style: videoStyle.videoDurationStyle ??
                          const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

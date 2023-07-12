import 'package:flutter/material.dart';
import 'package:lecle_yoyo_player/lecle_yoyo_player.dart';

/// A widget to display the video's current selected quality type.
class VideoQualityWidget extends StatelessWidget {
  /// Constructor
  const VideoQualityWidget({
    Key? key,
    required this.child,
    this.onTap,
    this.videoStyle = const VideoStyle(),
  }) : super(key: key);

  /// Callback function when user tap this widget to open the options list.
  final void Function()? onTap;

  /// The custom child to display the selected quality type.
  final Widget child;

  /// The model to provide custom style for the video display widget.
  final VideoStyle videoStyle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: videoStyle.videoQualityBgColor ?? Colors.grey,
          borderRadius: videoStyle.videoQualityRadius ??
              const BorderRadius.all(Radius.circular(5.0)),
        ),
        child: Padding(
          padding: videoStyle.videoQualityPadding ??
              const EdgeInsets.symmetric(horizontal: 5.0, vertical: 3.0),
          child: child,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

/// Video player custom style model
class VideoStyle {
  /// Custom play icon for play button.
  final Widget? playIcon;

  /// Custom pause icon for play button.
  final Widget? pauseIcon;

  /// Custom fullscreen icon for fullscreen button.
  final Widget? fullscreenIcon;

  /// Custom forward icon for the forward button.
  final Widget? forwardIcon;

  /// Custom backward icon for the backward button.
  final Widget? backwardIcon;

  /// Custom [TextStyle] for the video quality text. Default style is:
  /// ```dart
  /// const TextStyle(color: Colors.white)
  /// ```
  final TextStyle qualityStyle;

  /// A custom [TextStyle] for the supported quality options in the dropdown popup. Default style is:
  /// ```dart
  /// const TextStyle(color: Colors.white)
  /// ```
  final TextStyle qualityOptionStyle;

  /// A custom [TextStyle] for the video current position.
  final TextStyle? videoSeekStyle;

  /// A custom [TextStyle] for the video duration.
  final TextStyle? videoDurationStyle;

  /// When true, the widget will detect touch input and try to seek the video
  /// accordingly. The widget ignores such input when false.
  ///
  /// Defaults to false.
  final bool? allowScrubbing;

  /// The default colors used throughout the indicator.
  ///
  /// See [VideoProgressColors] for default values.
  final VideoProgressColors? progressIndicatorColors;

  /// This allows for visual padding around the progress indicator that can
  /// still detect gestures via [allowScrubbing].
  final EdgeInsets? progressIndicatorPadding;

  /// A custom padding for the video length values (current position and video's duration).
  final EdgeInsetsGeometry? videoDurationsPadding;

  /// A custom color for the play button's icon.
  final Color? playButtonIconColor;

  /// A custom size for the play button's icon.
  final double? playButtonIconSize;

  /// The space between play, forward and backward buttons. Default value is 8.0.
  final double spaceBetweenBottomBarButtons;

  /// A custom background color for the action bar that contains the
  /// fullscreen and the video quality buttons.
  final Color? actionBarBgColor;

  /// A custom padding for the action bar that contains the
  /// fullscreen and the video quality buttons.
  final EdgeInsetsGeometry? actionBarPadding;

  /// A custom background color for the quality options popup.
  final Color? qualityOptionsBgColor;

  /// A custom margin to change the display position for the quality options popup.
  final EdgeInsetsGeometry? qualityOptionsMargin;

  /// A custom padding around the video quality option text.
  final EdgeInsetsGeometry? qualityOptionsPadding;

  /// A custom border radius for the quality options popup.
  final BorderRadius? qualityOptionsRadius;

  /// The space between the fullscreen and the video quality buttons. Default value is 8.0.
  final double qualityButtonAndFullScrIcoSpace;

  /// A custom size for the forward and backward buttons.
  final double? forwardAndBackwardBtSize;

  /// A custom color for the forward button. Default color is [Colors.white].
  final Color forwardIconColor;

  /// A custom color for the backward button. Default color is [Colors.white].
  final Color backwardIconColor;

  /// The padding around for the bottom bar. Default value is:
  ///
  /// ```dart
  /// const EdgeInsets.symmetric(horizontal: 16.0)
  /// ```
  final EdgeInsetsGeometry bottomBarPadding;

  /// A custom background color for the selected video quality widget.
  final Color? videoQualityBgColor;

  /// A custom border radius for the selected video quality widget.
  final BorderRadiusGeometry? videoQualityRadius;

  /// The padding around for the selected video quality text.
  final EdgeInsetsGeometry? videoQualityPadding;

  /// The width for each item inside the video options popup. Default width is 90.0.
  final double qualityOptionWidth;

  /// Custom size for the full screen button's icon. Default size is 30.
  final double fullScreenIconSize;

  /// Custom color for the fullscreen button. Default color is [Colors.white].
  final Color fullScreenIconColor;

  /// If set to true, the direct button that use for a live stream video will be appeared and vice versa.
  final bool showLiveDirectButton;

  /// A custom display text for the live direct button.
  final String? liveDirectButtonText;

  /// A custom [TextStyle] for the text of live direct button.
  final TextStyle? liveDirectButtonTextStyle;

  /// A custom color for the live direct button. Default color is [Colors.red].
  final Color liveDirectButtonColor;

  /// A custom color for the live direct button. Default color is [Colors.grey].
  final Color liveDirectButtonDisableColor;

  /// A custom size for the live direct button. The size button's size is 10 by default.
  final double liveDirectButtonSize;

  /// If set to true the package will init the default orientations for the app.
  /// If you want to handle your app's orientations programmatically just set this property to false.
  final bool enableSystemOrientationsOverride;

  /// Specifies the set of orientations the application interface can
  /// be displayed in.
  ///
  /// The [orientation] argument is a list of [DeviceOrientation] enum values.
  /// The empty list causes the application to defer to the operating system
  /// default.
  final List<DeviceOrientation>? orientation;

  /// 标题
  final Widget? title;

  /// 动作条按钮集合
  final List<Widget>? actions;

  // 底部右侧按钮集合
  final List<Widget>? bottomBarRightActions;

  /// Constructor
  const VideoStyle({
    this.bottomBarRightActions,
    this.actions,
    this.title,
    this.playIcon,
    this.pauseIcon,
    this.fullscreenIcon,
    this.forwardIcon,
    this.backwardIcon,
    this.qualityStyle = const TextStyle(color: Colors.white),
    this.qualityOptionStyle = const TextStyle(color: Colors.white),
    this.videoDurationStyle,
    this.videoSeekStyle,
    this.videoDurationsPadding,
    this.progressIndicatorPadding,
    this.progressIndicatorColors,
    this.allowScrubbing,
    this.playButtonIconColor,
    this.playButtonIconSize,
    this.spaceBetweenBottomBarButtons = 8.0,
    this.actionBarBgColor,
    this.actionBarPadding,
    this.qualityOptionsBgColor,
    this.qualityOptionsMargin,
    this.qualityOptionsPadding,
    this.qualityOptionsRadius,
    this.qualityButtonAndFullScrIcoSpace = 8.0,
    this.forwardAndBackwardBtSize,
    this.backwardIconColor = Colors.white,
    this.forwardIconColor = Colors.white,
    this.bottomBarPadding = const EdgeInsets.symmetric(horizontal: 16.0),
    this.videoQualityBgColor,
    this.videoQualityRadius,
    this.videoQualityPadding,
    this.qualityOptionWidth = 90.0,
    this.fullScreenIconSize = 30.0,
    this.fullScreenIconColor = Colors.white,
    this.showLiveDirectButton = false,
    this.liveDirectButtonText,
    this.liveDirectButtonTextStyle,
    this.liveDirectButtonColor = Colors.red,
    this.liveDirectButtonDisableColor = Colors.grey,
    this.liveDirectButtonSize = 10,
    this.enableSystemOrientationsOverride = true,
    this.orientation,
  });
}

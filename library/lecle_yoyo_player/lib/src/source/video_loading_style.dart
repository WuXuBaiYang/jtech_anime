import 'package:flutter/material.dart';

/// A model to provide the custom values for the loading video widget
class VideoLoadingStyle {
  /// A custom loading widget to replace the default loading widget.
  final Widget? loading;

  /// Custom background color for the loading widget.
  final Color? loadingBackgroundColor;

  /// Custom color for the loading indicator. If the value is null the color will be [Colors.amber]
  final Color? loadingIndicatorValueColor;

  /// Custom loading text of the loading widget.
  final String? loadingText;

  /// Custom [TextStyle] for the loading text.
  final TextStyle? loadingTextStyle;

  /// The progress indicator's background color.
  ///
  /// It is up to the subclass to implement this in whatever way makes sense
  /// for the given use case. See the subclass documentation for details.
  final Color? loadingIndicatorBgColor;

  /// {@macro flutter.progress_indicator.ProgressIndicator.color}
  final Color? loadingIndicatorColor;

  /// The width of the line used to draw the circle. Default value is 4.0.
  final double loadingIndicatorWidth;

  /// {@macro flutter.progress_indicator.ProgressIndicator.semanticsLabel}
  final String? indicatorSemanticsLabel;

  /// {@macro flutter.progress_indicator.ProgressIndicator.semanticsValue}
  final String? indicatorSemanticsValue;

  /// If non-null, the value of this progress indicator.
  ///
  /// A value of 0.0 means no progress and 1.0 means that progress is complete.
  /// The value will be clamped to be in the range 0.0-1.0.
  ///
  /// If null, this progress indicator is indeterminate, which means the
  /// indicator displays a predetermined animation that does not indicate how
  /// much actual progress is being made.
  final double? indicatorInitialValue;

  /// The space between the loading text and the loading indicator.
  final double spaceBetweenIndicatorAndText;

  /// If you want to show both the loading indicator and the loading text you can set this property to [true]
  /// and [false] to show the loading indicator only.
  final bool showLoadingText;

  /// Constructor
  const VideoLoadingStyle({
    this.loading,
    this.loadingText,
    this.loadingTextStyle,
    this.loadingIndicatorValueColor,
    this.loadingBackgroundColor,
    this.loadingIndicatorBgColor,
    this.loadingIndicatorColor,
    this.loadingIndicatorWidth = 4.0,
    this.indicatorSemanticsLabel,
    this.indicatorSemanticsValue,
    this.indicatorInitialValue,
    this.spaceBetweenIndicatorAndText = 8.0,
    this.showLoadingText = true,
  });
}

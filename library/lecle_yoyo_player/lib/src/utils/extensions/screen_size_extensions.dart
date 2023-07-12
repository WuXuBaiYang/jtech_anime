import 'package:flutter/material.dart';

/// The extension methods for [Size] class
extension SizeExtension on Size {
  /// The method to calculate the aspect ratio from a given size
  double calculateAspectRatio() {
    final width = this.width;
    final height = this.height;
    return width > height ? width / height : height / width;
  }
}

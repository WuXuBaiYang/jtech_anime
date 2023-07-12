import 'package:flutter/services.dart';

class ScreenUtils {
  static void toggleFullScreen(bool fullScreen) {
    if (fullScreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
      ]);
    }
  }
}

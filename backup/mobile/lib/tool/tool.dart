import 'package:flutter/services.dart';

// 修改屏幕方向
void setScreenOrientation(bool portrait) {
  SystemChrome.setPreferredOrientations([
    if (portrait) ...[
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ] else ...[
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]
  ]);
}

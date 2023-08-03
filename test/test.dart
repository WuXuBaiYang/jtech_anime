import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jtech_anime/common/common.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('test', () async {
    final savePath =
        'a/c.b.cd/flutter_app/${FileDirPath.videoCachePath}/ijioasjdoih1o23io';
    print(savePath.substring(savePath.indexOf(FileDirPath.videoCachePath)));
  });
}

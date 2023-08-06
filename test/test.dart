import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jtech_anime/common/common.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('test', () async {
    for (int i = 0; i < 4; i++) {
      print('--------------$i');
    }
  });
}
